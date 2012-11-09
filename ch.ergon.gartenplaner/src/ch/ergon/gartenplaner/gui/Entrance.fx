/*
 	Entrance.fx

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
import javafx.scene.control.Button;
import javafx.scene.layout.VBox;
import javafx.scene.paint.Color;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;

/**
 * Starting mask.
 * @author albin
 */

package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        fill: Color.rgb(125, 180, 100) // a nice light green. wanted black, but checkboxes don't work with stylesheets, so no white text possible
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        content: [
            VBox {
                spacing: 30;
                layoutY: 40;
                layoutX: 80;
                content: [
                    Label {
                        text: "Willkommen beim Gartenplaner!\n\nHier können Sie planen, wann Sie welche Aktivitäten für welche Pflanzen in welchem Beet ausführen müssen in Ihrem Garten.\nDie Aktivitäten werden auf Monatsbasis geplant und abgehakt, wenn sie im Garten tatsächlich durchgeführt worden sind.\nSie können folgende Aktivitäten verwalten: Saen im Saatbeet, Pikieren, Saen im Garten, Setzen im Garten, Ernten, Düngen.\nDer Gartenplaner kennt viele Pflanzen und Dünger. Er bietet auch einen Ratgeber an bei pflanzenspezifischen Problemen.\nEr hilft bei der Auswahl der Pflanzen und Dünger abhängig von Bodenzustand und Nachbarpflanzen im selben Beet.\nEs werden für jede Pflanze sinnvolle Vorschläge für den Zeitpunkt (Monat) der Aktivitäten gemacht.\nDie Aktivitätszeitpunkte können im Beetkalender geändert werden.\nDas Programm berechnet den Bodenzustand der Beete aufgrund der benutzten Pflanzen und Dünger, z.B. Säure, Stickstoffgehalt usw.\nDie Zahlenwerte des Bodenzustands können auch von Hand geändert werden, je nachdem, was Sie in Ihrem Garten beobachten.\nSie können jedem Beet für jedes Jahr einen eigenen Namen geben, z.B. Schwachzerrerbeet, Frühbeet usw.\nFalls Sie im Garten keinen Computer benutzen, können Sie den Gartenplan einfach zuhause ausdrucken und auf Papier mitnehmen.\n\nDrücken Sie bitte einen der 3 Knöpfe!"
                        styleClass: "gardenPlanerSmallBlack"
                    }
                    HBox {
                        content: [
                                Button {
                                    text: "Neuer Garten"
                                    action: function() {
                                        BedDesign.reset(); // ugly, but how else to refresh the beddesign gui before starting it?
                                        scene.stage.scene = BedDesign.scene;
                                    }
                                }
                                Label {
                                    text: " um einen neuen Garten und dessen Beete zu designen."
                                    styleClass: "gardenPlanerSmallBlack"
                                }
                            ]
                    }
                    HBox {
                        content: [
                                Button {
                                    text: "Lade Garten"
                                    action: function() {
                                        LoadGarden.gardenList = LoadGarden.loadGardenList(); // ugly, but I don't know, how else to refresh the list of gardens in the LoadGarden-Mask
                                        scene.stage.scene = LoadGarden.scene;
                                    }
                                }
                                Label {
                                    text: " um einen bestehenden Garten zu planen und bearbeiten."
                                    styleClass: "gardenPlanerSmallBlack"
                                }
                        ]
                    }
                    HBox {
                        content: [
                                Button {
                                    text: "Beenden"
                                    action: function() {
                                        FX.exit();
                                    }
                                }
                                Label {
                                    text: " um das Gartenplaner-Programm zu beenden."
                                    styleClass: "gardenPlanerSmallBlack"
                                }
                        ]
                    }
                    HBox {
                        content: [
                                Label {
                                    text: "Dieses Programm wurde umgesetzt durch Albin Meyer von der Firma Ergon Informatik AG in Zürich (Schweiz), www.ergon.ch\nSie dürfen es gratis benutzen und weiterverteilen. Sie haben jedoch kein Anrecht auf Support.\nDer Autor übernimmt keine Verantwortung für irgendwelche Auswirkungen, die dieses Programm haben könnte.\nFeedback bitte per Email an albin.meyer@ergon.ch schicken. Vielen Dank."
                                    styleClass: "gardenPlanerSmallBlack"
                                }
                        ]
                    }
                ]
            }
        ]
}
