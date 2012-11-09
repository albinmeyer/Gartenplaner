/*
 	ChoosePlant.fx

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
import ch.ergon.gartenplaner.entity.data.Bed;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.layout.LayoutInfo;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import ch.ergon.gartenplaner.entity.def.DefPlant;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.stage.Alert;
import javafx.scene.paint.Color;
import java.lang.Error;
import java.lang.RuntimeException;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.shape.Rectangle;
import javafx.scene.layout.Panel;
import javafx.scene.Node;
import javafx.animation.transition.FadeTransition;
import javafx.scene.input.MouseEvent;


/**
 * Maske für Pflanze auswählen.
 * @author albin
 */

package var bed : Bed = bind GardenPlan.currentBed;
var year : Number = bind GardenPlan.planningYear;

package class PlantListViewItem {
    package var plant: DefPlant;
    public override function toString() {
        // the string to be displayed in the choice list in the mask
        plant.getName();
    }
}

package function loadPlantList(
            guteNachbarn : Boolean,
            guteNachfolger : Boolean,
            schlechteNachfolger : Boolean,
            schlechteNachbarn : Boolean,
            alle : Boolean) : PlantListViewItem[] {
    var col  = DefPlant.getPlants(bed, year, guteNachbarn, guteNachfolger, schlechteNachfolger, schlechteNachbarn, alle);
    listView.clearSelection(); // so selectedPlant gets null
    visibleDesc = false;

    // workaround to javafx not providing a nice modal popup solution
    GartenplanerAlert.closeModalAlertPopup();

    for(p in col) {
        PlantListViewItem {
            plant: p
        }
    }
}

function planPlant(): Void {
    try {
        if(selectedPlant != null) {
            // persist the added plant
            bed.addPlant(selectedPlant.plant, year, GardenPlan.currentYear, GardenPlan.currentMonth);
            DatabaseManager.saveBed(bed);

            // go back to garden plan, refreshing the current plant plan
            GardenPlan.refreshBedAndGrid();
//                                            GardenPlan.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
            scene.stage.scene = GardenPlan.scene;
        } else {
           GartenplanerAlert.showAlert("Keine Pflanze selektiert.", scene);
        }
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
}

package var plantList = bind loadPlantList(guteNachbarn, guteNachfolger, schlechteNachfolger, schlechteNachbarn, alle);

var listView : ListView = ListView {
    items: bind plantList;
    vertical: true;
    layoutInfo: LayoutInfo {
        vfill: false;
        height: 350;
        minWidth: 400; maxWidth: 400; width: 400
    }
    onMouseClicked: function(me: MouseEvent) {
        if(me.clickCount >= 2) {
            // double click on a list item
            planPlant();
        }
    }
}

package var selectedPlant: PlantListViewItem = bind listView.selectedItem as PlantListViewItem on replace {
        visibleDesc = true;
        GartenplanerAlert.closeModalAlertPopup();
        plantImage = Image {
                        url: "{__DIR__}{selectedPlant.plant.getPicFileName()}"
                        height: 80
                        width: 80
                    }    
    };

package var visibleDesc = false; // workaround to javafx not redrawing description label when updating plantlist after checkbox change
package var guteNachbarn = true;
package var guteNachfolger = true;
package var schlechteNachfolger = false;
package var schlechteNachbarn = false;
package var alle = false;
package var plantImage : Image;

package var sceneNode: Node = VBox {
                layoutX: 100
                layoutY: 20
                content: [
                    HBox {
                        spacing: 20
                        content: [
                            VBox {
                                content: [
                                    Label {
                                        text: "Wählen Sie eine Pflanze aus"
                                        styleClass: "gardenPlanerBlack"
                                    }
                                    listView,
                                    // check box boxes are not shown if using stylesheets, this is a known bug in javafx 1.3
                                    CheckBox {
                                        text: "gute Nachbarn (berücksichtigt bereits geplante Pflanzen im Beet)";
                                        selected: bind guteNachbarn with inverse
                                    }
                                    CheckBox {
                                        text: "gute Nachfolger (berücksichtigt Bodenbeschaffenheit im Beet)";
                                        selected: bind guteNachfolger with inverse
                                    }
                                    CheckBox {
                                        text: "schlechte Nachfolger (berücksichtigt Bodenbeschaffenheit im Beet)";
                                        selected: bind schlechteNachfolger with inverse
                                    }
                                    CheckBox {
                                        text: "schlechte Nachbarn (berücksichtigt bereits geplante Pflanzen im Beet)";
                                        selected: bind schlechteNachbarn with inverse
                                    }
                                    CheckBox {
                                        text: "alle";
                                        selected: bind alle with inverse
                                    }
                                    Label {
                                        text: "\nBemerkung: Falls eine Bodenbeschaffenheit zwischen 40% und 60% hat,\nund wenn sie im Vergleich zum Vorjahr mehr als 20% geändert hat,\ngilt sie als ideal für Mittelzerrer.\nFalls sie weniger als 40% ist, sollte die Pflanze sie fürchten.\nFalls sie mehr als 60% ist, sollte die Pflanze sie mögen.\n"
                                    }
                                ]
                            }
                            Panel {
                                content: [
                                    Rectangle {
                                        // the border of the plant image
                                        stroke: Color.ORANGE
                                        strokeWidth: 3
                                        arcWidth: 5
                                        arcHeight: 5
                                        y: 0
                                        height: 80
                                        width: 80
                                    }
                                    ImageView {
                                        image: bind plantImage;
                                    }
                                 ]
                            }
                            Label {
                                text: bind if (selectedPlant == null) then "-" else selectedPlant.plant.getDescription();
                                visible: bind visibleDesc; // workaround javafx bug not binding selectedPlant correctly to the text of this label
                            }
                        ]
                    }
                    HBox {
                        content: [
                                Label {
// javafx-rendering problem: if I set fix size of this text, the plant pic and plant desc are not always rendered properly!
//                                    width: 924
//                                    textWrap: true
                                    text: bind bed.getAllPlantsText()
                                }
                            ]
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
                            Button {
                                text: "Pflanze planen"
                                action: function() {
                                    planPlant();
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

// calling fadeintransition.playFromStart() will slowly fade in this mask
// but: it does not work properly, when using this at mask change when assigning a new scene to the stage.
// it then flickers sometimes the gui, before starting the fade with black
package var fadeintransition = FadeTransition {
    duration: 2s
    node: sceneNode
    repeatCount: 1
    autoReverse: true
    fromValue: 0.0
    toValue: 10.0
}