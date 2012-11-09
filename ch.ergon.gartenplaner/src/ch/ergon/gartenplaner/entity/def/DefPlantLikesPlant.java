/*
 	DefPlantLikesPlant.java

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
import javax.persistence.Entity;
import javax.persistence.ManyToOne;

/**
 * Association of plants liking each other.
 * @author albin
 */
@Entity
public class DefPlantLikesPlant {
    @Id
    // no sequence needed, because it's a readonly table for hibernate
    private int defPlantLikesPlantNo;

    @ManyToOne
    private DefPlant likesPlant;

    @ManyToOne
    private DefPlant thisPlant;

    public DefPlant getLikesPlant() {
        return likesPlant;
    }

}
