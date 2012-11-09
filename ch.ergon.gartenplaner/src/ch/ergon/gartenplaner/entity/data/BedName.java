/*
 	BedName.java

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

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;

/**
 * A name for a bed for one year, e.g. Schwachzerrerbeet, Brachbeet, ...
 * @author albin
 */
@Entity
public class BedName {

    /**
     * Constructor for loading the record from db.
     */
    public BedName() {

    }

    /**
     * Constructor
     */
    public BedName(int year, String name) {
        this.year = year;
        this.name = name;
    }

    @Id
    @GeneratedValue(strategy=GenerationType.SEQUENCE)
    private int bedNo;

    @ManyToOne
    private Bed bed;

    @Column(nullable = false)
    private int year;

    @Column
    private String name;

    public int getYear() {
        return year;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setBed(Bed bed) {
        this.bed = bed;
    }
}
