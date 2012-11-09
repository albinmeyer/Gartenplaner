/*
 	Bed.java

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
import ch.ergon.gartenplaner.entity.def.DefFertilizer;
import ch.ergon.gartenplaner.entity.def.DefFertilizerChangesGroundCharacteristic;
import ch.ergon.gartenplaner.entity.def.DefGroundCharacteristic;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import ch.ergon.gartenplaner.entity.def.DefPlantNeedsGroundCharacteristic;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import javax.persistence.CascadeType;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.OrderBy;


/**
 * One bed of a garden.
 * @author albin
 */
@Entity
public class Bed {

    /**
     * Constructor for loading the record from db.
     */
    public Bed() {

    }

    /**
     * Constructor for creating the record at bed-design time.
     * @param garden
     * @param x
     * @param y
     * @param width
     * @param height
     */
    public Bed(Garden garden, int x, int y, int width, int height) {
        this.garden = garden;
        this.topCoord = y;
        this.leftCoord = x;
        this.width = width;
        this.height = height;
        this.groundCharList = new ArrayList<BedHasGroundCharacteristic>();

        // now setting up the nutrientlist
        Collection<DefGroundCharacteristic> nutrientColl = DatabaseManager.getGroundCharacteristics();
        for(DefGroundCharacteristic dn : nutrientColl) {
            this.groundCharList.add(new BedHasGroundCharacteristic(dn, this));
        }

    }

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int bedNo;

    @Column(nullable = false)
    private int topCoord;

    @Column(nullable = false)
    private int leftCoord;

    @Column(nullable = false)
    private int width;

    @Column(nullable = false)
    private int height;

    @ManyToOne
    private Garden garden;

    @OneToMany(mappedBy = "bed", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<BedHasGroundCharacteristic> groundCharList = new ArrayList<BedHasGroundCharacteristic>();

    @OneToMany(mappedBy = "bed", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("year")
    private List<PlantPlan> plantPlanList = new ArrayList<PlantPlan>();

    @OneToMany(mappedBy = "bed", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    @OrderBy("year")
    private List<BedName> bedNameList = new ArrayList<BedName>();

    public int getTopCoord() {
        return this.topCoord;
    }

    public int getLeftCoord() {
        return this.leftCoord;
    }

    public int getWidth() {
        return this.width;
    }

    public int getHeight() {
        return this.height;
    }

    public Garden getGarden() {
        return this.garden;
    }

    /**
     * adds a plantplan to this bed.
     * @param plant the plant to be planted in this bed
     * @param year the planned year
     * @param currentYear the current year
     * @param currentMonth the current month
     */
    public void addPlant(DefPlant plant, int year, int currentYear, int currentMonth) {
        for(int yearOffset = 0; yearOffset < plant.getYears(); yearOffset++) {
            // go through all years of multiple years plants and create a plant plan for each year
            PlantPlan pp = new PlantPlan(this, plant, year, currentYear, currentMonth, yearOffset);
            plantPlanList.add(pp);
            year++;
        }
    }

    public void addFertilizer(DefFertilizer fertilizer, int year, int currentYear, int currentMonth) {
        PlantPlan pp = new PlantPlan(this, fertilizer, year, currentYear, currentMonth);
        plantPlanList.add(pp);
    }

    public List<PlantPlan> getPlantPlanList(int year) {
        List<PlantPlan> filteredPlantPlanList = new ArrayList<PlantPlan>();
        for(PlantPlan pp : this.plantPlanList) {
            if(pp.getYear() == year) {
                filteredPlantPlanList.add(pp);
            }
        }
        return filteredPlantPlanList;
    }

    public List<PlantPlan> getPlantPlanListCurrYear() {
        List<PlantPlan> filteredPlantPlanList = new ArrayList<PlantPlan>();
        for(PlantPlan pp : this.plantPlanList) {
            if(pp.getYear() == this.garden.getCurrentYear()) {
                filteredPlantPlanList.add(pp);
            }
        }
        return filteredPlantPlanList;
    }

    public boolean removePlantPlan(PlantPlan pp) {
        return plantPlanList.remove(pp);
    }

    public List<BedHasGroundCharacteristic> getGroundCharList() {
        return Collections.unmodifiableList(groundCharList);
    }

    /**
     * updates the nutrient amounts of this bed for a month, depending on the plants currently on this bed.
     * @param yearChange if the month changes from dec to jan
     */
    public void updateGroundCharacteristicAmountsForAMonth(boolean yearChange) {
        if(yearChange) {
            // updating last year amounts of bed ground charateristics
            for(BedHasGroundCharacteristic bedGroundChar : this.groundCharList) {
                bedGroundChar.updateLastYearAmount();
            }
        }
        List<PlantPlan> ppList = getPlantPlanListCurrYear();
        int nofPlantsInBed = 0;
        for(PlantPlan pp : ppList) {
            if(pp.getPlant() != null) {
                // it's a plant activity, not a fertilizer activity, so increase the number of plants in this bed
                nofPlantsInBed++;
            }
        }
        for(PlantPlan pp : ppList) {
            DefPlant dp = pp.getPlant();
            if(dp != null) {
                Collection<DefPlantNeedsGroundCharacteristic> needNutCol = dp.getNeedsNutrientList();
                for(DefPlantNeedsGroundCharacteristic nn : needNutCol) {
                    int amount = nn.getAmount();
                    DefGroundCharacteristic groundChar = nn.getGroundCharacteristic();
                    for(BedHasGroundCharacteristic bedGroundChar : this.groundCharList) {
                        if(bedGroundChar.getGroundCharacteristic().equals(groundChar)) {
                            // increase by amount proportional for this month to the whole year, regarding saen und ernten months
                            //TODO mehrjaehrige pflanzen: wenn es im nächsten Jahr wieder ein Ernten gibt ohne etwas anderes dazwischen, dann den monat beruecksichtigen
                            int saenMonth = 1; // default value at beginning of year, if no saen activity in plantplan
                            int erntenMonth = 12; // default value at end of year, if no ernten activity in plantplan
                            ConcreteActivity saenA = pp.getFirstIntoBedActivity();
                            if(saenA != null) {
                                saenMonth = saenA.getMonth();
                            }
                            ConcreteActivity erntenA = pp.getErntenActivity();
                            if(erntenA != null) {
                                erntenMonth = erntenA.getMonth();
                            }
                            int months = erntenMonth - saenMonth;
                            if(this.getGarden().getCurrentMonth() >= saenMonth && this.getGarden().getCurrentMonth() < erntenMonth) {
                                // if in the current month, there is something about this plant in the bed, adjust the amount of the ground characteristic
                                bedGroundChar.setAmount(bedGroundChar.getAmount() - amount/nofPlantsInBed/months);
                            }
                        }
                    }
                }
            }
            DefFertilizer df = pp.getFertilizer();
            if(df != null) {
                ConcreteActivity ca = pp.getConcreteActivity(this.getGarden().getCurrentMonth());
                if(ca != null) {
                    // this fertilizer was applied this month, so calculate new ground characteristics
                    List<DefFertilizerChangesGroundCharacteristic> changeGroundCharacteristicsList = df.getChangeGroundCharacteristicsList();
                    for(DefFertilizerChangesGroundCharacteristic fertChangeGroundChar : changeGroundCharacteristicsList) {
                        int amount = fertChangeGroundChar.getAmount();
                        DefGroundCharacteristic groundChar = fertChangeGroundChar.getGroundCharacteristic();
                        for(BedHasGroundCharacteristic bedGroundChar : this.groundCharList) {
                            if(bedGroundChar.getGroundCharacteristic().equals(groundChar)) {
                                bedGroundChar.setAmount(bedGroundChar.getAmount() + amount);
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     * Get a text for showing in the GUI containing all plants of this bed,
     * ordered by year, from the past through the present to the future.
     * @return the text
     */
    public String getAllPlantsText() {
        String allPlantsText = "Alle Pflanzen und Düngungen des selektierten Beets:\n";
        if(plantPlanList.isEmpty()) {
            allPlantsText += "noch keine vorhanden";
        } else {
            // assuming the plantPlanList is ordered by year
            int actualYear = 0;
            boolean firstOfYear = false;
            for(PlantPlan pp : plantPlanList) {
                if(pp.getYear() != actualYear) {
                    firstOfYear = true;
                    if(actualYear != 0) {
                        allPlantsText += ".\n";
                    }
                    actualYear = pp.getYear();
                    if(actualYear == this.getGarden().getCurrentYear()) {
                        allPlantsText += "Dieses Jahr";
                    } else {
                        allPlantsText += "Im Jahr " + actualYear;
                    }
                    for(BedName bedName : bedNameList) {
                        if(bedName.getYear() == actualYear) {
                            allPlantsText += " mit Beetname " + bedName.getName();
                        }
                    }
                    allPlantsText += ": ";
                }
                if(!firstOfYear) {
                    allPlantsText += ", ";
                }
                allPlantsText += pp.getName();
                firstOfYear = false;
            }
            allPlantsText += ".";
        }
        return allPlantsText + "\n";
    }

    public String getName(int year) {
        for(BedName bedName : bedNameList) {
            if(bedName.getYear() == year) {
                return bedName.getName();
            }
        }
        return "<beetname>";
    }

    public void setName(int year, String name) {
        for(BedName bedName : bedNameList) {
            if(bedName.getYear() == year) {
                bedName.setName(name);
                return;
            }
        }
        BedName bedName = new BedName(year, name);
        bedName.setBed(this);
        bedNameList.add(bedName);
    }

    @Override
    public String toString() {
        return "Bed x=" + this.leftCoord + ",y=" + this.topCoord;
    }
}
