/*
 	Main.fx

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

package ch.ergon.gartenplaner.gui;

import javafx.stage.Stage;
import ch.ergon.gartenplaner.app.GartenplanerConstants;

/**
 * Main JavaFX file with stage.
 * @author albin
 */


Stage {
    title: "Gartenplaner V1.00 - Copyright (c) 2011 - Albin Meyer (Ergon Informatik AG)";
    scene: Entrance.scene
    width: GartenplanerConstants.SCENE_WIDTH
    height: GartenplanerConstants.SCENE_HEIGHT
}