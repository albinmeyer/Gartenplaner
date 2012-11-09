/*
 	DatabaseManager.java

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

package ch.ergon.gartenplaner.entity;

import ch.ergon.gartenplaner.entity.data.Bed;
import ch.ergon.gartenplaner.entity.data.BedHasGroundCharacteristic;
import ch.ergon.gartenplaner.entity.data.ConcreteActivity;
import ch.ergon.gartenplaner.entity.data.Garden;
import ch.ergon.gartenplaner.entity.data.PlantPlan;
import ch.ergon.gartenplaner.entity.def.DefFertilizer;
import ch.ergon.gartenplaner.entity.def.DefGroundCharacteristic;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import ch.ergon.gartenplaner.entity.def.DefProblem;
import java.util.Collection;
import java.util.List;
import javax.persistence.Persistence;
import javax.persistence.EntityManager;
import javax.persistence.Query;

/**
 * Access to the database.
 * @author albin
 */
public class DatabaseManager {

    // since the database is embedded in this one and only application, it is ok to have the entity manager as a singleton
    private static EntityManager em = Persistence.createEntityManagerFactory("gartenplaner").createEntityManager();

    public static Collection<DefFertilizer> getFertilizer() {
        Query query = em.createQuery("SELECT f FROM DefFertilizer f ORDER BY f.name");
        Collection<DefFertilizer> res = query.getResultList();
        return res;
    }

    public static Collection<DefPlant> getPlants() {
        Query query = em.createQuery("SELECT dp FROM DefPlant dp ORDER BY dp.name");
        Collection<DefPlant> res = query.getResultList();
        return res;
    }

    public static Collection<DefPlant> getUsefulPlants() {
        Query query = em.createQuery("SELECT dp FROM DefPlant dp WHERE usefulFor IS NOT NULL ORDER BY dp.name");
        Collection<DefPlant> res = query.getResultList();
        return res;
    }

    public static Collection<DefProblem> getProblemsOfAllPlants() {
        Query query = em.createQuery("SELECT dp FROM DefProblem dp WHERE dp.relatedToAllPlants = 1 ORDER BY dp.title");
        Collection<DefProblem> res = query.getResultList();
        return res;
    }

    public static List<Garden> getGardens() {
        Query query = em.createQuery("SELECT ga FROM Garden ga ORDER BY ga.name");
        List<Garden> res = query.getResultList();
        return res;
    }

    public static List<DefGroundCharacteristic> getGroundCharacteristics() {
        Query query = em.createQuery("SELECT dn FROM DefGroundCharacteristic dn ORDER BY dn.name");
        List<DefGroundCharacteristic> res = query.getResultList();
        return res;
    }

    public static boolean saveNewGarden(Garden garden) {
        Query query = em.createQuery("SELECT ga FROM Garden ga WHERE ga.name = :name");
        query.setParameter("name", garden.getName());
        List<Garden> res = query.getResultList();
        if(!res.isEmpty()) {
            // name already exists
            return false;
        }
        em.getTransaction().begin();
        em.persist(garden);
        em.getTransaction().commit();
        return true;
    }

    public static void saveGarden(Garden garden) {
        em.getTransaction().begin();
        em.persist(garden);
        em.getTransaction().commit();
    }

    public static void deleteGarden(Garden garden) {
        em.getTransaction().begin();
        em.remove(garden);
        em.getTransaction().commit();
    }

    public static void saveBed(Bed bed) {
        em.getTransaction().begin();
        em.persist(bed);
        em.getTransaction().commit();

        em.refresh(bed); // to get correct order of plantplans on bed
    }

    public static void saveConcreteActivity(ConcreteActivity ca) {
        em.getTransaction().begin();
        em.persist(ca);
        em.getTransaction().commit();
    }

    public static void saveBedGroundCharacteristic(BedHasGroundCharacteristic gc) {
        em.getTransaction().begin();
        em.persist(gc);
        em.getTransaction().commit();
    }

    public static void deleteConcreteActivity(ConcreteActivity ca) {
        em.getTransaction().begin();
        ca.getPlantPlan().deleteConcreteActivity(ca);
        em.remove(ca);
        em.getTransaction().commit();
    }

    public static void deletePlantPlan(PlantPlan pp) {
        em.getTransaction().begin();
        em.remove(pp);
        em.getTransaction().commit();
    }
}
