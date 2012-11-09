/*
 	BedHasGroundCharacteristic.java

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

import ch.ergon.gartenplaner.entity.def.DefGroundCharacteristic;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.ManyToOne;

/**
 * One ground characteristic of one bed.
 * @author albin
 */
@Entity
public class BedHasGroundCharacteristic {

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int bedHasGroundCharacteristicNo;

    @Column(nullable = false)
    private int amount;  // percentage 0-100%

    @Column(nullable = false)
    private int lastYearAmount; // amount end of of last year

    @Column(nullable = false)
    private boolean changedMuch; // whether the amount changed much from last year to this year

    @ManyToOne
    private Bed bed;

    @ManyToOne
    private DefGroundCharacteristic groundCharacteristic;

    /**
     * Constructor for loading the record from DB.
     */
    public BedHasGroundCharacteristic() {

    }

    /**
     * Constructor called when creating a record (at bed-design time).
     * @param dn
     */
    public BedHasGroundCharacteristic(DefGroundCharacteristic dn, Bed bed) {
        this.amount = 50;  // default starting ground characteristic amount
        this.groundCharacteristic = dn;
        this.bed = bed;
        this.lastYearAmount = 50;
        this.changedMuch = false;
    }

    public boolean getChangedMuch() {
        return changedMuch;
    }

    public void updateLastYearAmount() {
        if(lastYearAmount - amount < 20 && lastYearAmount - amount > -20) {
            changedMuch = false;
        } else {
            changedMuch = true;
        }
        lastYearAmount = amount;
    }

    public int getAmount() {
        return amount;
    }

    public void setAmount(int amount) {
        if(amount < 0) {
            amount = 0;
        }
        if(amount > 100) {
            amount = 100;
        }
        this.amount = amount;
    }

    public DefGroundCharacteristic getGroundCharacteristic() {
        return groundCharacteristic;
    }

    @Override
    public String toString() {
        return this.groundCharacteristic.getName() + this.amount;
    }
}
