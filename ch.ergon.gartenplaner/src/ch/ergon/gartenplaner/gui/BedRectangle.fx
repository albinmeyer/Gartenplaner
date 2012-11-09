/*
 	BedRectangle.fx

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
import javafx.scene.Group;
import ch.ergon.gartenplaner.entity.data.Bed;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import ch.ergon.gartenplaner.entity.data.PlantPlan;
import javafx.scene.Node;
import ch.ergon.gartenplaner.entity.data.ConcreteActivity;
import javafx.scene.control.Label;
import javafx.stage.Alert;
import java.lang.Error;
import java.lang.RuntimeException;
import javafx.scene.layout.Panel;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.control.Tooltip;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.text.Text;

/**
 * Ein Beet-Rechteck im Gartenplan.
 * @author albin
 */

public var currentBed : Bed;
package var currentBedRectangle : BedRectangle;

/**
* draw the contents (plants+actions) for the current month of the garden.
*/
function drawBedContent(bed: Bed) : Node [] {
    try {
        var nodes : Node[];
        var offsetx = 0; // the number of the plant in the bed (for drawing them one after another on the x axis)
        var offsety = 0; // the number of the plant row in the bed
        var tooltip = Tooltip {
                    text: "Klicken Sie auf das Pflanzenbild, um Problemlösungsvorschläge zu erhalten."
                }


        // now draw the contents of this bed (the plants)
        for(pp : PlantPlan in bed.getPlantPlanListCurrYear()) {
            var ca : ConcreteActivity = pp.getConcreteActivity(bed.getGarden().getCurrentMonth());
            if(pp.getPlant() != null) {
                // draw the plant
                insert Panel {
                        content: [
                            Rectangle {
                                // the border of the plant image in the bed
                                stroke: Color.ORANGE
                                strokeWidth: 3
                                arcWidth: 5
                                arcHeight: 5
                                x: GartenplanerConstants.PLANT_PIC_INBED_WIDTH*offsetx + 5
                                y: GartenplanerConstants.PLANT_PIC_Y_INBED_DELTA*offsety + 5
                                height: GartenplanerConstants.PLANT_PIC_INBED_HEIGHT
                                width: GartenplanerConstants.PLANT_PIC_INBED_WIDTH
                            }
                            ImageView {
                                // placing the images one after another on the x-axis
                                x: GartenplanerConstants.PLANT_PIC_INBED_WIDTH*offsetx + 5
                                y: GartenplanerConstants.PLANT_PIC_Y_INBED_DELTA*offsety + 5
                                image: Image {
                                    url: "{__DIR__}{pp.getPlant().getPicFileName()}"
                                    height : GartenplanerConstants.PLANT_PIC_INBED_HEIGHT
                                    width: GartenplanerConstants.PLANT_PIC_INBED_WIDTH
                                }
                                onMouseEntered: function(e): Void {
                                    tooltip.activate();
                                }
                                onMouseExited: function(e): Void {
                                    tooltip.deactivate();
                                }

                                // show problem gui, if clicked on plant picture
                                onMouseClicked: function(e): Void {
                                    Problems.plant = pp.getPlant();
                                    Problems.refresh(); // workaround to javafx not automatically refresh a guimask on loading it
                                    var imgView = e.source as ImageView;
//                                    Problems.fadeintransition.playFromStart(); // does not work properly, sometimes show first fully and then start to fadein
                                    imgView.scene.stage.scene = Problems.scene;
                                }
                            }
                            tooltip
                        ]
                } into nodes;
            } else if (ca != null) {
                // show the name of the fertilizer, because this month there is an activity for this fertilizer
                insert Label {
                    layoutX: GartenplanerConstants.PLANT_PIC_INBED_WIDTH*offsetx + 5;
                    layoutY: GartenplanerConstants.PLANT_PIC_Y_INBED_DELTA*offsety + 5;
                    width: GartenplanerConstants.PLANT_PIC_INBED_WIDTH
                    styleClass: "gardenPlaner"
                    textWrap: true
                    text: pp.getName()
                } into nodes;
            } else {
                // nothing to draw for this plantplan
                continue;
            }

            // draw the activity of the current month, if there is any
            if(ca != null) {
                // putting the activity 40 pixels below the plant pic
                insert GardenPlan.getDonableActivity(ca, GartenplanerConstants.PLANT_PIC_INBED_WIDTH*offsetx + 5, GartenplanerConstants.PLANT_PIC_INBED_HEIGHT + GartenplanerConstants.PLANT_PIC_Y_INBED_DELTA*offsety + 5) into nodes;
            }
            offsetx++; // go to next pic in same line
            if(bed.getWidth()
                < GartenplanerConstants.PLANT_PIC_INBED_WIDTH*offsetx
                    //+ GartenplanerConstants.PLANT_PIC_INBED_WIDTH
                    + 5) {
                // go to next line
                offsety++;
                offsetx = 0;
            }

         }
         return nodes;
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
     return null;
}

public class BedRectangle extends CustomNode {
    public var bed: Bed;
    public var color: Color = Color.rgb(60, 30, 10);

    override function create() {
        try {
            if(bed.equals(currentBed)) {
                // restore the color of the current bed.
                // needed when refreshing the whole gui,
                // but wanting the current bed still be with the color of the selected bed.
                color = Color.BROWN;
                currentBedRectangle = this;
            }
            var bedNameX = bed.getWidth()/2-20;
            if(bedNameX < 1) {
                bedNameX = 1;
            }
            var bedNameY = bed.getHeight()-5;
            if(bedNameY < 1) {
                bedNameY = 1;
            }
            return Group {
    // layout, if this node is used in a container
                layoutX: bind bed.getLeftCoord()
                layoutY: bind bed.getTopCoord()

    // translate, if this node is used inside a group
    //            translateX: bind centerX
    //            translateY: bind centerY

                content: [
                    // the bed itself
                    Rectangle {
                        stroke: Color.BLACK
                        strokeWidth: 0.5
                        arcWidth: 20
                        arcHeight: 20
                        x: 0
                        y: 0
                        height: bed.getHeight()
                        width: bed.getWidth()
                        fill: bind color // because the color changes when clicked on it
                    }
                    Text {
                        x: bedNameX
                        y: bedNameY
//                        styleClass: "gardenPlanerGreen"
                        fill: Color.GREEN
                        content: bed.getName(bed.getGarden().getCurrentYear())
                    }

                    // draw the contents of a bed (plant, activities)
                    drawBedContent(bed)
                ]

                onMousePressed: function(e): Void {
                    currentBed = bed;
                    // set this fresh selected bed to the selected color
                    color = Color.BROWN;
                    if(currentBedRectangle != null and currentBedRectangle != this) {
                        // go to old unselected color of previous selected bed
                        currentBedRectangle.color = Color.rgb(60, 30, 10);
                    }
                    currentBedRectangle = this;
                }
            };
         } catch (t: RuntimeException){
            Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
         } catch (t: Error){
            Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
         } // cannot catch Throwable, because javafx often throws NonLocalReturnException
         return null;
    }
}
