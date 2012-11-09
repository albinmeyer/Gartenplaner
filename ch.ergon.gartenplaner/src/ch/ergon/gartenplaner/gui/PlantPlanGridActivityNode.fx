/*
 	PlantPlanGridActivityNode.fx

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
import javafx.scene.layout.Stack;
import javafx.scene.paint.Color;
import javafx.scene.shape.Rectangle;
import java.lang.IllegalArgumentException;
import javafx.scene.control.Button;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.layout.LayoutInfo;
import ch.ergon.gartenplaner.entity.data.ConcreteActivity;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import javafx.scene.image.ImageView;
import javafx.stage.Alert;
import java.lang.Error;
import java.lang.RuntimeException;
import ch.ergon.gartenplaner.app.GartenplanerConstants;

/**
 * A single node in the plant plan grid, containing an activity, not a text.
 * @author albin
 */
// the three possible modes a column of the plant plan grid could be
public def PRESENT : Number = 1;
public def PAST : Number = 2;
public def FUTURE : Number = 3;

public class PlantPlanGridActivityNode extends CustomNode {
    public var concreteActivity : ConcreteActivity;
    public var activityImage : ImageView;
    public var backgroundColor : Number;

    override function create() {
        var color : Color;
        var canMoveActivityForward : Boolean;
        var canMoveActivityBackward : Boolean;
        if(backgroundColor == PRESENT) {
            color = Color.AQUA;
            canMoveActivityForward = true;
            canMoveActivityBackward = false;
        } else if(backgroundColor == PAST) {
            color = Color.AZURE;
            canMoveActivityForward = false;
            canMoveActivityBackward = false;
        } else if(backgroundColor == FUTURE) {
            color = Color.ROYALBLUE;
            canMoveActivityForward = true;
            canMoveActivityBackward = true;
        } else {
            throw new IllegalArgumentException("invalid color set on backgroundColor");
        }

        // returning a filled rectangle as background color of the text, and the text node itself on top of the background color rectangle
        return Stack {
            width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
            content: [
                Rectangle {
                    width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                    height: 40
                    fill: color;
                }
                VBox {
                    content : [
                        activityImage,
                        HBox {
                            content : [
                                Button {
                                    text: "<"
                                    disable: not canMoveActivityBackward
                                    layoutInfo: LayoutInfo {minWidth: 18 width: 18 maxWidth: 18 minHeight: 10 height: 10 maxHeight: 10} // width directly does not work
                                    action: function() {
                                        try {
                                            if(concreteActivity.decMonth()) {
                                                DatabaseManager.saveConcreteActivity(concreteActivity);
                                                GardenPlan.refreshBedAndGrid();
                                            } else {
                                                GartenplanerAlert.showAlert("Kann nicht auf einen Monat vor Januar springen.", scene);
                                            }
                                        } catch (t: RuntimeException){
                                            Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
                                        } catch (t: Error){
                                            Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
                                        } // cannot catch Throwable, because javafx often throws NonLocalReturnException
                                    }
                                }
                                Button {
                                    layoutInfo: LayoutInfo {minWidth: 18 width: 18 maxWidth: 18 minHeight: 10 height: 10 maxHeight: 10} // width directly does not work
                                    text: ">"
                                    disable: not canMoveActivityForward
                                    action: function() {
                                        try {
                                           if(concreteActivity.incMonth()) {
                                               DatabaseManager.saveConcreteActivity(concreteActivity);
                                               GardenPlan.refreshBedAndGrid();
                                           } else {
                                                GartenplanerAlert.showAlert("Kann nicht auf einen Monat nach Dezember springen.", scene);
                                           }
                                        } catch (t: RuntimeException){
                                           Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
                                        } catch (t: Error){
                                           Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
                                        } // cannot catch Throwable, because javafx often throws NonLocalReturnException
                                    }
                                }
                            ]
                        }
                    ]
                 }
            ]
        };
    }
}

