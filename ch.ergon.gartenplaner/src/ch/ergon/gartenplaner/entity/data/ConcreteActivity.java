/*
 	ConcreteActivity.java

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

import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.ManyToOne;

/**
 * One concrete activity of a plant/ferilizer for a bed.
 * @author albin
 */
@Entity
public class ConcreteActivity implements Comparable {

    /**
     * Constructor called by JPA when loading from DB.
     */
    public ConcreteActivity() {
    }

    /**
     * Constructor for a duengen activity.
     * @param plantPlan
     * @param name
     * @param month
     */
    public ConcreteActivity(PlantPlan plantPlan, String name, int month) {
        this.name = name;
        this.month = month;
        this.plantPlan = plantPlan;
        this.done = false;
    }

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int concreteActivityNo;

    @Column(nullable = false)
    private int month;

    @Column(nullable = false)
    private String name; // SAEN, SETZEN, WACHSEN, ERNTEN, PIKIEREN, SAATKASTEN

    @Column(nullable = false)
    private boolean done;

    @ManyToOne
    private PlantPlan plantPlan;

    /**
     * increments the month of this concrete activity.
     * Returns false, if it cannot be incremented, e.g. if already in december
     * @return
     */
    public boolean incMonth() {
        if(month >= 12) {
            return false;
        }
        done = false; // incMonth will sure be in the future and cannot be done
        month++;
        return true;
    }

    /**
     * derements the month of this concrete activity.
     * returns false, if it cannot be incremented, e.g. if already in januar
     * @return
     */
    public boolean decMonth() {
        if(month <= 1) {
            return false;
        }
        month--;
        return true;
    }

    public int getMonth() {
        return month;
    }

    public void setMonth(int month) {
        this.month = month;
    }

    public String getName() {
        return name;
    }

    public boolean isDone() {
        return done;
    }

    public void toggleDoneStatus() {
        done = !done;
    }

    public PlantPlan getPlantPlan() {
        return plantPlan;
    }

    public int getYear() {
        return getPlantPlan().getYear();
    }

    @Override
    public int compareTo(Object o) {
        ConcreteActivity ca = (ConcreteActivity) o;
        if(ca.getYear() == this.getYear() && ca.getMonth() == this.getMonth()) {
            // same month and year
            if(ca.getName().equals(this.getName()) && ca.getPlantPlan().equals(this.getPlantPlan())) {
                // equals
                return 0;
            } else {
                // same month, but not equals
                return 1;
            }
        } else if(ca.getYear() < this.getYear() || ca.getYear() == this.getYear() && ca.getMonth() < this.getMonth()) {
            // this object is AFTER the param obj
            return 1;
        } else {
            // this object is BEFORE the param obj
            return -1;
        }
    }

    @Override
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        }
        if(o instanceof ConcreteActivity) {
            ConcreteActivity ca = (ConcreteActivity) o;
            if(ca.getMonth() == this.getMonth()
                    && ca.getYear() == this.getYear()
                    && ca.getName().equals(this.getName())
                    && ca.getPlantPlan().equals(this.getPlantPlan())) {
                return true;
            }
        }
        return false;
    }

    @Override
    public int hashCode() {
        int result = 17;
        result = 37*result + this.getMonth();
        result = 37*result + this.getYear();
        result = 37*result + this.getName().hashCode();
        result = 37*result + this.getPlantPlan().hashCode();
        return result;
    }
}
