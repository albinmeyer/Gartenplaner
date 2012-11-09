/*
 	Garden.java

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

package ch.ergon.gartenplaner.entity.data;

import ch.ergon.gartenplaner.entity.DatabaseManager;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import ch.ergon.gartenplaner.entity.def.DefPlantNeedsGroundCharacteristic;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.OneToMany;

/**
 * One garden.
 * @author albin
 */
@Entity
public class Garden {

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int gardenNo;

    @Column(unique = true)
    private String name;

    @Column(nullable = false)
    private int currentYear;

    @Column(nullable = false)
    private int currentMonth;

    @OneToMany(mappedBy= "garden", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Bed> bedList = new ArrayList<Bed>();

    /**
     * Constructor for loading from DB.
     */
    public Garden() {
    }

    /**
     * Constructor for creating a new garden.
     * @param name
     * @param currentYear
     */
    public Garden(String name, int currentYear) {
        this.name = name;
        this.currentMonth = 1;
        this.currentYear = currentYear;
    }


    public void nextMonth() {
        // update nutrient amounts in beds
        for(Bed bed : bedList) {
            bed.updateGroundCharacteristicAmountsForAMonth(currentMonth == 12);
        }

        // update month/year of this garden
        currentMonth++;
        if(currentMonth > 12) {
            currentYear++;
            currentMonth = 1;
        }
    }

    public int getCurrentYear() {
        return this.currentYear;
    }

    public int getCurrentMonth() {
        return this.currentMonth;
    }

    public String getName() {
        return this.name;
    }
    public void addBed(Bed bed) {
        bedList.add(bed);
    }

    public List<Bed> getBedList() {
        return Collections.unmodifiableList(bedList);
    }

    /**
     * checks, whether all planned activities are done in the current month and year for this garden.
     * @return
     */
    public boolean allPlannedActivitiesDoneThisMonth() {
        for(Bed bed : bedList) {
            for(PlantPlan plantPlan : bed.getPlantPlanListCurrYear()) {
                if(plantPlan.hasUndoneConcreteActivity(this.currentMonth)) {
                    return false;
                }
            }
        }
        return true;
    }

    /**
     * return tipps for this garden, e.g. what plants are missing,
     * which plants are bad neighbors in this garden,
     * and how mixed the plants are.
     * @return
     */
    public String getTipps() {
        String tipps = "";

        // check if some useful plants are missing in the beds
        Collection<DefPlant> usefulPlants = DatabaseManager.getUsefulPlants();
        Collection<DefPlant> usedUsefulPlants = new HashSet<DefPlant>();
        for(DefPlant usefulPlant : usefulPlants) {
            for(Bed bed : bedList) {
                Collection<PlantPlan> plantPlanList = bed.getPlantPlanListCurrYear();
                for(PlantPlan pp : plantPlanList) {
                    if(usefulPlant.equals(pp.getPlant())) {
                        usedUsefulPlants.add(usefulPlant);
                    }
                }
            }
        }
        // now in usedUsefulPlants are all useful plants used in the garden
        usefulPlants.removeAll(usedUsefulPlants);
        // now in usefulPlants there are only unused useful plants
        for(DefPlant usefulPlant : usefulPlants) {
            tipps += usefulPlant.getName() + " fehlt in diesem Garten. " + usefulPlant.getUsefulFor() + "\n";
        }

        // now check bad neighbors
        for(Bed bed : bedList) {
            Collection<PlantPlan> plantPlanList = bed.getPlantPlanListCurrYear();
            for(PlantPlan pp : plantPlanList) {
                if(pp.getPlant() != null) {
                    for(PlantPlan ppNeighbour : plantPlanList) {
                        if(pp.equals(ppNeighbour)) {
                            break;
                        }
                        if(ppNeighbour.getPlant() != null) {
                            if(pp.getPlant().hates(ppNeighbour.getPlant())) {
                                tipps += "Diese beiden Pflanzen sollten nicht im selben Beet sein: " + pp.getName() + " und " + ppNeighbour.getName() + "\n";
                            }
                        }
                    }
                }
            }
        }


        // now check mischkultur
        int nofGc = DatabaseManager.getGroundCharacteristics().size();
        int starkzerrer = 0;
        int schwachzerrer = 0;
        int nofBeds = bedList.size();
        Collection<DefPlant> gardenPlants = new HashSet<DefPlant>();
        for(Bed bed : bedList) {
            Collection<PlantPlan> plantPlanList = bed.getPlantPlanListCurrYear();
            for(PlantPlan pp : plantPlanList) {
                if(pp.getPlant() != null) {
                    gardenPlants.add(pp.getPlant());
                    Collection<DefPlantNeedsGroundCharacteristic> dpngcCol = pp.getPlant().getNeedsNutrientList();
                    for(DefPlantNeedsGroundCharacteristic dpngc : dpngcCol) {
                        int amount = dpngc.getAmount();
                        if(amount > 0) {
                            starkzerrer ++;
                        } else if(amount < 0) {
                            schwachzerrer ++;
                        }
                    }
                }
            }
        }
        // there should be enough plants
        if(nofBeds >= gardenPlants.size()) {
            tipps += "Es existieren relativ wenig verschiedene Pflanzen im Garten, nur " + gardenPlants.size() + " für " + nofBeds + " Beete.\n";
        }
        // are there enough schwachzerrer?
        if(schwachzerrer <= gardenPlants.size()/nofGc) {
            tipps += "Es existieren relativ wenig Schwachzerrer im Garten.\n";
        }
        // are there enough starkzerrer?
        if(starkzerrer <= gardenPlants.size()/nofGc) {
            tipps += "Es existieren relativ wenig Starkzerrer im Garten.\n";
        }

        return tipps;
    }

    @Override
    public String toString() {
        return name;
    }
}
