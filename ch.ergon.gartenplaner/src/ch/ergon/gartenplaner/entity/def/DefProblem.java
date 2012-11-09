/*
 	DefProblem.java

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

import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;

/**
 * Table of possible problems of plants.
 * @author albin
 */
@Entity
public class DefProblem {
    @Id
    // no sequence needed, because it's a readonly table for hibernate
    private int defProblemNo;

    @Column(nullable = false)
    private String title;

    @Column
    private String description;

    @Column
    private String vorbeugenText;

    @Column
    private String behandelnText;

    @Column(nullable = false)
    private String picFileName;

    @Column
    private Boolean relatedToAllPlants; // if true, this problem is related to all plants

    /**
     * get the title of the problem.
     * @return
     */
    public String getName() {
        return title;
    }

    /**
     * return the filename of the picture of this problem.
     * @return
     */
    public String getPicFileName() {
        return picFileName;
    }

    /**
     * get the whole description of this problem, including solutions.
     * @return
     */
    public String getDescription() {
        return title + "\n\nBeschreibung:\n" + description + "\n\nVorbeugemassnahmen:\n" + vorbeugenText + "\n\nBehandlung:\n" + behandelnText;
    }
}
