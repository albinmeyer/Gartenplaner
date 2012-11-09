/*
 	Tipps.fx

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
import javafx.scene.paint.Color;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.Node;
import javafx.scene.layout.VBox;
import javafx.scene.control.Button;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;

var tippsString : String;

package function refresh() : Void {
    tippsString = GardenPlan.garden.getTipps();
}

package var sceneNode: Node = VBox {
    layoutX: 100
    layoutY: 20
    content: [
                    Label {
                        text: "Tipps für diesen Garten:\n"
                        styleClass: "gardenPlanerBlack"
                    }
                    Label {
                        text: bind tippsString
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {  // gap (workaround for rendering problems of javafx
                        text: "\n\n"
                    }
                    Label {
                        text: "Alle möglichen Aktivitäten im Gartenplaner:\n"
                        styleClass: "gardenPlanerBlack"
                    }
                    Label {
                        text: "Düngen"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}DUENGEN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {
                        text: "Aussaat in den Saatkasten"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}SAATKASTEN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {
                        text: "Pikieren"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}PIKIEREN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {
                        text: "Saen im Garten"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}SAEN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {
                        text: "Setzen im Garten"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}SETZEN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {
                        text: "Ernten"
                        graphic: ImageView {
                            image: Image {
                                url: "{__DIR__}ERNTEN.jpg"
                                height: GartenplanerConstants.ACTIVITY_PIC_HEIGHT // let 12 pixels space for the back/forward-buttons
                                width: GartenplanerConstants.ACTIVITY_PIC_WIDTH
                            }
                        }
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    Label {  // gap (workaround for rendering problems of javafx
                        text: "\n\n"
                    }
                    HBox {
                        content: [
                            Button {
                                text: "Zurück"
                                action: function() {
                                    // go back to garden plan without doing anything
//                                    GardenPlan.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
                                    scene.stage.scene = GardenPlan.scene;
                                }
                            }
                        ]
                    }
        ]
}

package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        fill: Color.rgb(125, 180, 100) // a nice light green. wanted black, but checkboxes don't work with stylesheets, so no white text possible
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        content: [
            sceneNode
        ]
}
