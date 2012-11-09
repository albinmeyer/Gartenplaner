/*
 	BedDesign.fx

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

import javafx.scene.Scene;
import javafx.scene.shape.Rectangle;
import javafx.scene.paint.Color;
import javafx.scene.input.MouseEvent;
import javafx.scene.Group;
import javafx.scene.control.Button;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;
import javafx.scene.control.Label;
import ch.ergon.gartenplaner.entity.data.Bed;
import ch.ergon.gartenplaner.entity.data.Garden;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import javafx.scene.control.TextBox;
import javafx.stage.Alert;
import java.lang.Error;
import java.lang.RuntimeException;
import javafx.scene.shape.Line;
import java.lang.ClassCastException;
import ch.ergon.gartenplaner.app.GartenplanerConstants;

/**
 * Maske um neue Beete zu zeichnen.
 * @author albin
 */
var canvas : Group = Group {};
var sr: Rectangle;
var s_X: Float;
var s_Y: Float;
var startYear: Integer = GartenplanerConstants.STARTING_YEAR;

/**
* if clicking on a already drawn rectangle (bed), delete it
*/
function getRectangle(x: Float, y: Float): Rectangle {
    Rectangle {
        id: "id{x}"
        x: x
        y: y
        fill: Color.TRANSPARENT
        onMousePressed: function (mouse) {
            for (rect in canvas.content) {
                if(rect.id == mouse.node.id) {
                    delete rect from canvas.content;
                    break;
                }

            }
        }
        stroke: Color.BLACK
        strokeWidth: 0.5
        arcWidth: 20
        arcHeight: 20
    };
}

package function reset() {
    // empty the garden name
    gardenName.text = "";
    startYear = GartenplanerConstants.STARTING_YEAR;

    // no current bed
    sr = null;

    // close any modal alert
    GartenplanerAlert.closeModalAlertPopup();
    
    // draw the canvas
    canvas.content = {
                // first draw the border of the whole garden
                Rectangle {
                    height: GartenplanerConstants.GARDEN_LAYOUT_HEIGHT
                    width: GartenplanerConstants.GARDEN_LAYOUT_WIDTH
                    fill: Color.rgb(40, 80, 30) // browngreen background color
                }
          };
    // now draw the help grid
    for(i in [1..79]) {
        insert Line {
                     startX: i*10 startY: 0
                     endX: i*10 endY: 500
                     stroke:Color.GREY
                     strokeWidth:1
                } into canvas.content;
    }
    for(j in [1..49]) {
        insert Line {
                     startX: 0 startY: j*10
                     endX: 800 endY: j*10
                     stroke:Color.GREY
                     strokeWidth:1
                } into canvas.content;
    }
}


/**
* if dragging mouse to create a new rectangle(bed), draw it
*/
function drawSR(m: MouseEvent) {
    // draw
    if (0 <= m.dragX ) {
        sr.width = m.dragX;
    } else {
        sr.x = s_X + m.dragX;
        sr.width = -m.dragX;
    }
    if (0 < m.dragY ) {
        sr.height = m.dragY;
    } else {
        sr.y = s_Y + m.dragY;
        sr.height = -m.dragY;
    }
    // but don't draw outside border
    if(sr.x + sr.width > 800) {
        sr.width = 800-sr.x;
    }
    if(sr.y + sr.height > 500) {
        sr.height = 500-sr.y;
    }

}

public var gardenName = TextBox {};

package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        fill: Color.BLACK        
        content: [
            // the bed rectangles to be drawn by the user
            Rectangle {
                width: bind canvas.scene.width - 1
                height: bind canvas.scene.height - 1
                fill: Color.TRANSPARENT
                onMousePressed: function (mouse) {
                    s_X = mouse.sceneX;
                    s_Y = mouse.sceneY;
                    if(s_X < 800 and s_Y < 500) {
                        // only draw inside border
                        sr = getRectangle(s_X, s_Y);
                        insert sr into canvas.content
                    }
                }
                onMouseDragged: function (mouse) {
                    drawSR(mouse)
                }
                onMouseReleased: function (mouse) {
                    //delete sr from canvas.content
                    sr.fill = Color.rgb(60, 30, 10);
                }
            },
            VBox {
                content: [
                    canvas,
                    HBox {
                        content: [
                            Label {
                                text: "Hier zeichnen Sie die Beete Ihres Gartens."
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "Ziehen Sie mit der Maus neue Beete. Klicken Sie auf ein gezeichnetes Beet, um es wieder zu löschen."
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "Der gesamte Garten wird durch ein Koordinatensystem mit der maximalen Breite 800.0 und der maximalen Höhe 500.0 beschrieben."
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "Diese Zahlen können, aber müssen nicht als cm verstanden werden. Falls Sie z.B. einen Garten mit den Massen 16.5m mal 12m haben,"
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "dann nehmen Sie für 2.5 echte cm eine Koordinateneinheit im Gartenplaner. D.h. Ihr Garten erhält die Masse 660.0 mal 480.0"
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "Ein Häuschen entspricht 10 mal 10 Koordinateneinheiten."
                                styleClass: "gardenPlanerSmall"
                            }
                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: bind "Aktuelles Beet: Koordinaten oben links x={sr.x}/y={sr.y}"
                                styleClass: "gardenPlanerSmall"
                            }

                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: bind "Aktuelles Beet: Koordinaten unten rechts x={sr.x + sr.width}/y={sr.y + sr.height}"
                                styleClass: "gardenPlanerSmall"
                            }
                            
                        ]
                    }
                    HBox { // gap, workaround to not correct working layout rendering of javaFX
                        content: [
                            Label {
                                text: ""
                                styleClass: "gardenPlanerSmall"
                            }

                        ]
                    }
                    HBox {
                        content: [
                            Label {
                                text: "Name des Gartens: "
                                styleClass: "gardenPlaner"
                            }
                            gardenName
                        ]
                    }
                    HBox {
                        content: [
                                    Label {
                                        text: "Startjahr der Planung: ";
                                        styleClass: "gardenPlaner"
                                    }
                                    Button {
                                        text: "<"
                                        action: function() {
                                            startYear--;
                                        }
                                    }
                                    Label {
                                        text: bind "{startYear}";
                                        styleClass: "gardenPlanerYear"
                                    }
                                    Button {
                                        text: ">"
                                        action: function() {
                                            startYear++;
                                        }
                                    }
                            ]
                    }
                    Label { // gap (workaround because I cannot explicitely set the HBox with the 2 buttons a bit lower)
                        text: ""
                        styleClass: "gardenPlaner"
                    }
                    HBox {
                        content: [
                            Button {
                                text: "Zurück (ohne Speichern)"
                                action: function() {
                                    scene.stage.scene = Entrance.scene;
                                }
                            }
                            Button {
                                text: "Speichern und Verlassen"
                                action: function() {
                                    try {
                                        // generate the entity class instances to persist
                                        var garden : Garden = new Garden(gardenName.text, startYear);
                                        for(item in canvas.content) {
                                            try {
                                                var r: Rectangle = item as Rectangle;
                                                if(r.width >= 800 and r.height >= 500) {
                                                    // it's the whole garden rectangle, don't save it
                                                    continue;
                                                }
                                                var bed : Bed = new Bed(garden, r.x, r.y, r.width, r.height);
                                                garden.addBed(bed);
                                            } catch(e: ClassCastException) {
                                                // it's a line of the grid
                                                continue;
                                            }
                                        }
                                        // persist
                                        if(DatabaseManager.saveNewGarden(garden)) {
                                            // zurueck
                                            scene.stage.scene = Entrance.scene;
                                        } else {
                                            GartenplanerAlert.closeModalAlertPopup(); // workaround to javafx not providing nice popup solution
                                            GartenplanerAlert.showAlert("Kann nicht speichern.\nDer Name des Gartens existiert bereits.", scene);
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
}
