/*
 	PrintFxUtils.fx

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

package ch.ergon.gartenplaner.print;

import java.awt.Container;
import java.awt.Frame;
import java.awt.image.BufferedImage;
import javax.swing.JFrame;
import ch.ergon.gartenplaner.app.GartenplanerConstants;

/**
 * Functions for printing a javafx scene.
 * @author albin
 */

function getContainer() : Container {
    var container : Container;
    var frames = Frame.getFrames();
    container = (frames[0] as JFrame).getContentPane();
    return container;
}

function toBufferedImage(container : Container) : BufferedImage {
    // print the scene, means whole screenshot with width and heigth
    var bufferedImage = new BufferedImage(GartenplanerConstants.SCENE_WIDTH, GartenplanerConstants.SCENE_HEIGHT, BufferedImage.TYPE_INT_ARGB);
    var graphics = bufferedImage.getGraphics();
    graphics.translate(0, 0); // left upper start coodinate of the screenshot
    container.paint(graphics);
    graphics.dispose();
    return bufferedImage;
}

function print(container : Container) {
    def image = toBufferedImage(container);
    PrintUtils.print(image);
}

/**
 * print the current scene to the printer.
 */
public function printScene() : Void {
    print(getContainer());
}