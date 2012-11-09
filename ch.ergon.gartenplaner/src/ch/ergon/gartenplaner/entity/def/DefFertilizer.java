/*
 	DefFertilizer.java

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
import java.util.Collection;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.TreeSet;
import javax.persistence.Id;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.OneToMany;

/**
 * Duenger.
 * @author albin
 */
@Entity
public class DefFertilizer implements Comparable {
    
    @Id
    // no sequence needed, because it's a readonly table for hibernate
    private int defFertilizerNo;

    @Column(nullable = false)
    private String name;

    @OneToMany(mappedBy= "fertilizer")
    private List<DefFertilizerChangesGroundCharacteristic> nutrientList;

    /**
     * Name des Duengers.
     * @return
     */
    public String getName() {
        return name;
    }

    /**
     * Welche Bodencharakteristiken durch diesen Duenger geaendert werden.
     * @return
     */
    public List<DefFertilizerChangesGroundCharacteristic> getChangeGroundCharacteristicsList() {
        return Collections.unmodifiableList(nutrientList);
    }

    /**
     * Detaillierte Beschreibung dieses Duengers, e.g. welche Bodenbeschaffenheit wie veraendert wird.
     * @return
     */
    public String getDescription() {
        String desc = "Beschreibung von " + this.name + "\n\nEine Anwendung ändert die Bodenbeschaffenheit in folgender Art:\n";
        if(nutrientList.isEmpty()) {
            desc += "-\n";
        } else {
            for(DefFertilizerChangesGroundCharacteristic fertChgc : nutrientList) {
                int amount = fertChgc.getAmount();
                if(amount < 0) {
                    desc += "Der Gehalt an " + fertChgc.getGroundCharacteristic().getName() + " wird um " + (-amount)  + "% reduziert.\n";
                } else {
                    desc += "Der Gehalt an " + fertChgc.getGroundCharacteristic().getName() + " wird um " + amount  + "% erhöht.\n";
                }
            }
            desc += "\nFalls Sie eine grössere Portion anwenden, planen Sie bitte entsprechend mehrere Aktivitäten\ndieser Düngung im selben Monat.";
        }
        return desc;
    }

    @Override
    public int compareTo(Object o) {
        DefFertilizer other = (DefFertilizer) o;
        return (this.getName().compareTo(other.getName()));
    }

    @Override
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        }
        if(o instanceof DefFertilizer) {
            DefFertilizer df = (DefFertilizer) o;
            if(df.getName().equals(this.getName())) {
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
     * Gets the fertilizer from the database, according to the desired wishes in the parameters.
     * @param bed
     * @param gute
     * @param schlechte
     * @param alle
     * @return
     */
    public static Collection<DefFertilizer> getFertilizer(Bed bed, boolean gute, boolean schlechte, boolean alle) {
        Collection<DefFertilizer> defFertList = DatabaseManager.getFertilizer();
        if(alle) {
            // just return all, ignoring the other arguments
            return defFertList;
        }
        Collection<DefFertilizer> defGuteFertList = new HashSet<DefFertilizer>();
        Collection<DefFertilizer> defSchlechteFertList = new HashSet<DefFertilizer>();

        List<BedHasGroundCharacteristic> groundCharList = bed.getGroundCharList();
        // go through all fertilizers (duenger)
        for(DefFertilizer f : defFertList) {
            int bad = 0; // counter, for how many nutrients this plant is bad
            // for each fertilizer, check all bed ground charactersitics with all ground chars of the fertilizer
            for(BedHasGroundCharacteristic groundChar : groundCharList) {
                DefGroundCharacteristic gc = groundChar.getGroundCharacteristic();
                int amount = groundChar.getAmount();
                for(DefFertilizerChangesGroundCharacteristic fertChangeGroundChar : f.getChangeGroundCharacteristicsList()) {
                   if(fertChangeGroundChar.getGroundCharacteristic().equals(gc)) {
                       if(fertChangeGroundChar.getAmount() > 0) {
                           if(amount > 60) {
                               bad ++;
                           } else if(amount < 40) {
                               bad --;
                           }
                       } else {
                           if(amount > 60) {
                               bad --;
                           } else if(amount < 40) {
                               bad ++;
                           }
                       }
                   }
                }
            }
            if(bad > 0) {
                defSchlechteFertList.add(f);
            } else if (bad < 0) {
                defGuteFertList.add(f);
            }
        }

        Collection<DefFertilizer> res = new TreeSet<DefFertilizer>();
        if(gute) {
            res.addAll(defGuteFertList);
        }
        if(schlechte) {
            res.addAll(defSchlechteFertList);
        }
        return res;
    }

}
