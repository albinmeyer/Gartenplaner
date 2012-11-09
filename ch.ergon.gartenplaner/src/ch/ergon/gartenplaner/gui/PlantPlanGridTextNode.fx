/*
 	PlantPlanGridTextNode.fx

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
import javafx.scene.CustomNode;
import javafx.scene.text.Text;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import javafx.scene.layout.Stack;
import java.lang.IllegalArgumentException;
import ch.ergon.gartenplaner.app.GartenplanerConstants;

/**
 * A single node in the plant plan grid, containing a text, not an activity.
 * @author albin
 */

// the three possible modes a column of the plant plan grid could be
public def PRESENT : Number = 1;
public def PAST : Number = 2;
public def FUTURE : Number = 3;

public class PlantPlanGridTextNode extends CustomNode {
    public var text : String;
    public var backgroundColor : Number;

    override function create() {
        var color : Color;
        if(backgroundColor == PRESENT) {
            color = Color.AQUA
        } else if(backgroundColor == PAST) {
            color = Color.AZURE
        } else if(backgroundColor == FUTURE) {
            color = Color.ROYALBLUE
        } else {
            throw new IllegalArgumentException("invalid color set on backgroundColor");
        }

        // returning a filled rectangle as background color of the text, and the text node itself on top of the background color rectangle
        Stack {
            content: [
                Rectangle {
                    width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                    height: 40
                    fill: color;
                }
                Text {
                    layoutInfo: LayoutInfo {minWidth: 40 width: 40 maxWidth: 40} // width directly on Label does not work
                    content: text
                }
            ]
        }
    }
}
