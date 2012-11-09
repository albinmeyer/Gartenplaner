/*
 	DefPlant.java

 	Gartenplaner - A program to plan works in the garden.

 	Copyright (c) 2011 by Albin Meyer
 	albin.meyer@ergon.ch
 	http://www.ergon.ch/

 	This program is free software; you can redistribute it and/or modify
 	it under the terms of the GNU General Public License as published by
 	the Free Software Foundation; either version 2 of the License, or
 	(at your option) any later version.

 	This program is distributed in the hope that it will be useful,
 	but WITHOUT ANY WARRANTY; without even the implied warranty of
 	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 	GNU General Public License for more details.

 	You should have received a copy of the GNU General Public License
 	along with this program; If not, see <http://www.gnu.org/licenses/>.

 	Last updated: Jan 3, 2011
*/

package ch.ergon.gartenplaner.entity.def;

import ch.ergon.gartenplaner.entity.DatabaseManager;
import ch.ergon.gartenplaner.entity.data.Bed;
import ch.ergon.gartenplaner.entity.data.BedHasGroundCharacteristic;
import ch.ergon.gartenplaner.entity.data.PlantPlan;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.TreeSet;
import javax.persistence.CascadeType;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.OneToMany;

/**
 * A definition of a plant, like e.g. Erdbeere, Kartoffel, Karotte, Tomate.
 * @author albin
 */
@Entity
public class DefPlant implements Comparable {
    @Id
    // no sequence needed, because it's a readonly table for hibernate
    private int defPlantNo;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private int years; // how many years this plant typically resides in the bed

    @Column(nullable = false)
    private String picFileName;

    @Column
    private String usefulFor; // why this plant should not be missed in any garden (nullable), used by "Tipps"

    @OneToMany(mappedBy= "thisPlant", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<DefPlantLikesPlant> likesPlantList;

    @OneToMany(mappedBy= "thisPlant", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<DefPlantHatesPlant> hatesPlantList;

    @OneToMany(mappedBy= "thisPlant", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<DefPlantNeedsGroundCharacteristic> needsNutrientList;

    @OneToMany(mappedBy= "plant", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<DefPlant2Problem> problemList;

    @OneToMany(mappedBy= "plant", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<DefDefaultActivity> defaultActivityList;

    @Override
    public String toString() {
        return this.name;
    }

    public List<DefPlantNeedsGroundCharacteristic> getNeedsNutrientList() {
        return Collections.unmodifiableList(this.needsNutrientList);
    }

    public List<DefDefaultActivity> getDefaultActivityList() {
        return Collections.unmodifiableList(this.defaultActivityList);
    }

    /**
     * get a list of problems related exactly to this plant, and also those problems related to all plants.
     * @return
     */
    public List<DefProblem> getProblemList() {
        List<DefProblem> problems = new ArrayList<DefProblem>();
        for(DefPlant2Problem plantProblem : problemList) {
            problems.add(plantProblem.getProblem());
        }
        problems.addAll(DatabaseManager.getProblemsOfAllPlants());
        return problems;
    }

    /**
     * get the name of this plant.
     * @return
     */
    public String getName() {
        return name;
    }

    /**
     * return the string what this plant is useful for.
     * @return
     */
    public String getUsefulFor() {
        return usefulFor;
    }

    /**
     * including file extension like png or jpg or gif.
     * @return
     */
    public String getPicFileName() {
        return picFileName;
    }

    /**
     * Does this plant like the given plant?
     * @param plant
     * @return
     */
    public boolean likes(DefPlant plant) {
        for(DefPlantLikesPlant dplp : likesPlantList) {
            if(dplp.getLikesPlant().equals(plant)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Does this plant hate the given plant?
     * @param plant
     * @return
     */
    public boolean hates(DefPlant plant) {
        for(DefPlantHatesPlant dphp : hatesPlantList) {
            if(dphp.getHatesPlant().equals(plant)) {
                return true;
            }
        }
        return false;
    }

    /**
     * how many years does this plant reside in a bed?
     * @return
     */
    public int getYears() {
        return years;
    }

    /**
     * a description about this plant, e.g. whom it likes/hates, what it needs.
     * @return
     */
    public String getDescription() {
        String desc = "Beschreibung von " + this.name + ":\n\nBleibt " + this.years + " Jahr(e) im Beet.\n\nGute Nachbarn:\n";
        if(likesPlantList.isEmpty()) {
            desc += "-\n";
        } else {
            for(DefPlantLikesPlant dplp : likesPlantList) {
                desc += dplp.getLikesPlant().getName() + "\n";
            }
        }
        desc += "\nSchlechte Nachbarn:\n";
        if(hatesPlantList.isEmpty()) {
            desc += "-\n";
        } else {
            for(DefPlantHatesPlant dphp : hatesPlantList) {
                desc += dphp.getHatesPlant().getName() + "\n";
            }
        }
        desc += "\nWunsch an die Bodenbeschaffenheit:\n";
        if(needsNutrientList.isEmpty()) {
            desc += "-\n";
        } else {
            for(DefPlantNeedsGroundCharacteristic nn : this.needsNutrientList) {
                int amount = nn.getAmount();
                if(amount > 0) {
                    desc += "Mag " + nn.getGroundCharacteristic().getName() + ".";
                    if(amount > 1) {
                        // Some ground characteristics like sonnenschein, temperatur are not changed by the plant, they get the amount 1
                        // and don't need following text in the gui mask
                        desc += " Benötigt " + amount + "% pro Jahr.";
                    }
                    desc += "\n";
                } else if(amount < 0) {
                    desc += "Fürchtet sich vor zuviel " + nn.getGroundCharacteristic().getName() + ".";
                    if(amount < -1) {
                        // Some ground characteristics like sonnenschein, temperatur are not changed by the plant, they get the amount -1
                        // and don't need following text in the gui mask
                        desc += " Erzeugt " + (-amount) + "% pro Jahr.";
                    }
                    desc += "\n";
                } else {
                    // mittelzerrer amount == 0
                    desc += "Mittelzerrer für " + nn.getGroundCharacteristic().getName() + ". Verursacht keine Änderung.\n";
                }
            }
        }
        desc += "\nTypische Aktivitäten:\n";
        if(defaultActivityList.isEmpty()) {
            desc += "-\n";
        } else {
            for(DefDefaultActivity da : this.defaultActivityList) {
                desc += da.getName() + " im Monat " + da.getMonth() + "\n";
            }
        }
        return desc;
    }

    @Override
    public int compareTo(Object o) {
        DefPlant other = (DefPlant) o;
        return (this.getName().compareTo(other.getName()));
    }

    @Override
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        }
        if(o instanceof DefPlant) {
            DefPlant dp = (DefPlant) o;
            if(dp.getName().equals(this.getName())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public int hashCode() {
        int result = 17;
        result = 37*result + this.getName().hashCode();
        return result;
    }


    /**
     * Gets the plants from the database according to the desires defined in the bool params
     * @param bed the bed for which plants are to be retrieved
     * @param planningYear the year a plant will be planned
     * @param guteNachbarn
     * @param guteNachfolger
     * @param schlechteNachfolger
     * @param schlechteNachbarn
     * @param alle
     * @return
     */
    public static Collection<DefPlant> getPlants(Bed bed, int planningYear, boolean guteNachbarn, boolean guteNachfolger, boolean schlechteNachfolger, boolean schlechteNachbarn, boolean alle) {
        Collection<DefPlant> defPlantList = DatabaseManager.getPlants();

        if(alle) {
            // just return all, ignoring the other arguments
            return defPlantList;
        }

        Collection<DefPlant> resGuteNachbarn = new HashSet<DefPlant>();
        Collection<DefPlant> resGuteNachfolger = new HashSet<DefPlant>();
        Collection<DefPlant> resSchlechteNachfolger = new HashSet<DefPlant>();
        Collection<DefPlant> resSchlechteNachbarn = new HashSet<DefPlant>();

        // check already planned plants in this bed (gute/schlechte Nachbarn)
        List<PlantPlan> plantPlanList = bed.getPlantPlanList(planningYear);
        for(PlantPlan pp : plantPlanList) {
            for(DefPlant dp : defPlantList) {
                if(dp.likes(pp.getPlant())) {
                    resGuteNachbarn.add(dp);
                }
                if(dp.hates(pp.getPlant())) {
                    resSchlechteNachbarn.add(dp);
                }
            }
        }

        // a guter nachbar cannot be a schlechte nachbar at the same time
        Collection<DefPlant> likeAndHate = new HashSet<DefPlant>();
        for(DefPlant dp: resGuteNachbarn) {
            if(resSchlechteNachbarn.contains(dp)) {
                likeAndHate.add(dp);
            }
        }
        resGuteNachbarn.removeAll(likeAndHate);
        resSchlechteNachbarn.removeAll(likeAndHate);


        // gutenachfolger, schlechtenachfolger
        Collection<BedHasGroundCharacteristic> bedNutrientCol= bed.getGroundCharList();
        for(DefPlant plant : defPlantList) {
            if(resSchlechteNachbarn.contains(plant)) {
                // keep this plant in schlechte nachbarn only, even if it were a good nachfolger
                continue;
            }
            // per default, assuming it is a good nachfolger, may remove it later again from the list
            resGuteNachfolger.add(plant);
            int bad = 0; // counter, for how many nutrients this plant is bad
            boolean badChanged = false;
            for(BedHasGroundCharacteristic nut : bedNutrientCol) {
                List<DefPlantNeedsGroundCharacteristic> plantNeedNutList = plant.getNeedsNutrientList();
                for(DefPlantNeedsGroundCharacteristic pnn : plantNeedNutList) {
                    if(pnn.getGroundCharacteristic().equals(nut.getGroundCharacteristic())) {
                        if(nut.getAmount() < 40) {
                            if(pnn.getAmount() > 0) {
                                // the bed lacks this nutrient, the plant needs it => bad
                                bad ++;
                                if(nut.getAmount() < 25) {
                                    bad ++; // very bad
                                }
                            } else if(pnn.getAmount() < 0) {
                                // the bed lacks this nutrient, the plant generates it => good
                                bad --;
                            }
                            badChanged = true;                            
                        } else if(nut.getAmount() > 60) {
                            if(pnn.getAmount() > 0) {
                                // the bed has this nutrient, the plant needs it => good
                                bad --;
                            } else if(pnn.getAmount() < 0) {
                                // the bed has this nutrient, the plant generates it => bad
                                bad ++;
                                if(nut.getAmount() > 75) {
                                    bad ++; // very bad
                                }
                            }
                            badChanged = true;
                        } else if(pnn.getAmount() == 0 && nut.getChangedMuch()) {
                            // bed amount is between 40 and 60, ideal for mittelzerrer.
                            // mittelzerrer is good, if the nutrient in the bed changed much
                            bad --;
                            badChanged = true;
                        } else if(pnn.getAmount() != 0 && !nut.getChangedMuch()) {
                            // bed amount is between 40 and 60
                            // schwach and starkzerrer are good, if the nutrient in bed has not changed much
                            bad --;
                            badChanged = true;
                        }
                    }
                }
            }
            if(bad > 0) {
                // this plant is a bad nachfolger
                resSchlechteNachfolger.add(plant);
                // don't want it in a good list
                resGuteNachbarn.remove(plant);
                resGuteNachfolger.remove(plant);
            } else if(bad == 0 && badChanged) {
                // it's not bad, but also not good, and at least one aspect is bad (because badChanged is true)
                resGuteNachfolger.remove(plant);
            }
        }

        // now putting together the result depending on the values of the bool params
        Collection<DefPlant> res = new TreeSet<DefPlant>();
        if(guteNachbarn) {
            res.addAll(resGuteNachbarn);
        }
        if(guteNachfolger) {
            res.addAll(resGuteNachfolger);
        }
        if(schlechteNachfolger) {
            res.addAll(resSchlechteNachfolger);
        }
        if(schlechteNachbarn) {
            res.addAll(resSchlechteNachbarn);
        }
        return res;
    }

}
