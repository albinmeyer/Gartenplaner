/*
 	PlantPlan.java

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

import ch.ergon.gartenplaner.entity.def.DefDefaultActivity;
import ch.ergon.gartenplaner.entity.def.DefFertilizer;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import java.util.Collection;
import java.util.List;
import java.util.TreeSet;
import javax.persistence.CascadeType;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;

/**
 * The plan for either putting a plant or fertilizer to a bed,
 * containing the activities for achieving this goal.
 * @author albin
 */
@Entity
public class PlantPlan {

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int plantPlanNo;

    @ManyToOne
    private DefPlant plant;

    @ManyToOne
    private DefFertilizer fertilizer;

    @ManyToOne
    private Bed bed;

    @Column(nullable = false)
    private int year;

    @OneToMany(mappedBy= "plantPlan", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private Collection<ConcreteActivity> concreteActivityList = new TreeSet<ConcreteActivity>();

    /**
     * Constructor called by jpa when loading from db.
     */
    public PlantPlan() {

    }

    /**
     * Constructor, creates a plan for one fertilizer in a bed.
     * The activity is set to the current month.
     * @param bed
     * @param plant
     * @param year
     * @param currentYear
     * @param currentMonth
     */
    public PlantPlan(Bed bed, DefFertilizer fertilizer, int year, int currentYear, int currentMonth) {
        this.fertilizer = fertilizer;
        this.bed = bed;
        this.year = year;
        concreteActivityList.add(new ConcreteActivity(this, "DUENGEN", currentMonth));
    }

    /**
     * Constructor. creates a plan for one plant in a bed.
     * if the default activity months are past to the actual month, those concrete activities
     * are automatically moved to the next available free month slot.
     * @param bed
     * @param plant
     * @param plannedYear the planned year for planting the plant
     * @param currentYear the current year
     * @param currentMonth the current month
     * @param yearOffset the number of years from the starting planning year (if the plant is a multiple year plant)
     */
    public PlantPlan(Bed bed, DefPlant plant, int plannedYear, int currentYear, int currentMonth, int yearOffset) {
        this.plant = plant;
        this.bed = bed;
        this.year = plannedYear;
        List<DefDefaultActivity> defaultActivityList = plant.getDefaultActivityList();
        Collection<ConcreteActivity> activitiesInThePast = new TreeSet<ConcreteActivity>();
        // fill the list of concrete activities of this plant plan
        for(DefDefaultActivity defaultActivity : defaultActivityList) {
            if(defaultActivity.getMonth() > yearOffset * 12 && defaultActivity.getMonth() <= (yearOffset + 1) * 12) {
                // only if this plant plan belongs to the year where this activity is planned
                ConcreteActivity concreteActivity = new ConcreteActivity(this, defaultActivity.getName(), defaultActivity.getMonth() - yearOffset * 12);
                concreteActivityList.add(concreteActivity);
                if(concreteActivity.getYear() < currentYear || concreteActivity.getMonth() < currentMonth && concreteActivity.getYear() == currentYear) {
                    activitiesInThePast.add(concreteActivity);
                }
            }
        }
        // move the month of any concrete activity of the past into the next free month slot
        for(ConcreteActivity caPast : activitiesInThePast) {
            int loopMonth = -1;
            for(ConcreteActivity caPlanned : concreteActivityList) {
                if(caPlanned.getYear() > currentYear || caPlanned.getYear() == currentYear && caPlanned.getMonth() >= currentMonth) {
                    // present or future
                    if(loopMonth > -1) {
                        if(caPlanned.getMonth() -1 > loopMonth && loopMonth < 12) {
                            // found a slot
                            caPast.setMonth(loopMonth + 1);
                            break;
                        } else {
                            loopMonth = caPlanned.getMonth();
                        }
                    } else if(caPlanned.getYear() == currentYear && caPlanned.getMonth() > currentMonth) {
                        // future, so set the past activity to the present
                        caPast.setMonth(currentMonth);
                        break;
                    } else {
                        // present, so save current Month and proceed loop
                        loopMonth = caPlanned.getMonth();
                    }
                }
            }
            if(caPast.getYear() < currentYear || caPast.getYear() == currentYear && caPast.getMonth() < currentMonth) {
                // still in past
                if(loopMonth > -1 && loopMonth < 12) {
                    caPast.setMonth(loopMonth + 1);
                } else {
                    caPast.setMonth(currentMonth);
                }
                //TODO mehrjaehrige pflanzen: move the past activity to the next year, if no slot found in this year
            }
        }
    }

    public DefPlant getPlant() {
        return plant;
    }

    public DefFertilizer getFertilizer() {
        return fertilizer;
    }

    /**
     * get first found (the oldest) concrete activity for the given month.
     * @param month
     * @return
     */
    public ConcreteActivity getConcreteActivity(int month) {
        for(ConcreteActivity concreteActivity : concreteActivityList) {
            if(concreteActivity.getMonth() == month) {
                return concreteActivity;
            }
        }
        return null;
    }

    public boolean hasUndoneConcreteActivity(int month) {
        for(ConcreteActivity concreteActivity : concreteActivityList) {
            if(concreteActivity.getMonth() == month) {
                if(!concreteActivity.isDone()) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * gets the first activity of this plantplan when the plant gets into the bed (saen or setzen).
     * @return
     */
    public ConcreteActivity getFirstIntoBedActivity() {
        for(ConcreteActivity concreteActivity : concreteActivityList) {
            if(concreteActivity.getName().equals("SAEN") || concreteActivity.getName().equals("SETZEN")) {
                return concreteActivity;
            }
        }
        return null;
    }

    /**
     * gets the activity of ernten.
     * @return
     */
    public ConcreteActivity getErntenActivity() {
        for(ConcreteActivity concreteActivity : concreteActivityList) {
            if(concreteActivity.getName().equals("ERNTEN")) {
                return concreteActivity;
            }
        }
        return null;
    }

    public boolean deleteConcreteActivity(ConcreteActivity ca) {
        return concreteActivityList.remove(ca);
    }

    public int getYear() {
        return year;
    }

    public String getName() {
        if(plant != null) {
            return plant.getName();
        } else if(fertilizer != null) {
            return fertilizer.getName();
        } else {
            // must never happen
            return "<error>";
        }
    }
}
