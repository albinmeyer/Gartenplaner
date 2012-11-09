/*
 	ChooseFertilizer.fx

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

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

import javafx.scene.Scene;
import ch.ergon.gartenplaner.entity.data.Bed;
import javafx.scene.layout.VBox;
import javafx.scene.layout.HBox;
import javafx.scene.control.Label;
import javafx.scene.control.ListView;
import javafx.scene.layout.LayoutInfo;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import javafx.scene.control.Button;
import javafx.scene.control.CheckBox;
import javafx.stage.Alert;
import javafx.scene.paint.Color;
import ch.ergon.gartenplaner.entity.def.DefFertilizer;
import java.lang.Error;
import java.lang.RuntimeException;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.Node;
import javafx.animation.transition.FadeTransition;
import javafx.scene.input.MouseEvent;


/**
 * Maske um die Düngung auszuwählen.
 * @author albin
 */

package var bed : Bed = bind GardenPlan.currentBed;
var year : Number = bind GardenPlan.planningYear;

package class FertilizerListViewItem {
    package var fertilizer: DefFertilizer;
    public override function toString() {
        // the string to be displayed in the choice list in the mask
        fertilizer.getName();
    }
}

package function loadFertilizerList(
            gute : Boolean,
            schlechte : Boolean,
            alle : Boolean) : FertilizerListViewItem[] {
    var col  = DefFertilizer.getFertilizer(bed, gute, schlechte, alle);
    listView.clearSelection(); // so selectedPlant gets null
    visibleDesc = false;

    // workaround to javafx not providing a nice modal popup solution
    GartenplanerAlert.closeModalAlertPopup();
    
    for(f in col) {
        FertilizerListViewItem {
            fertilizer: f
        }
    }
}

function planFertilizer() : Void {
    try {
        if(selectedFertilizer != null) {
            // persist the added plant
            bed.addFertilizer(selectedFertilizer.fertilizer, year, GardenPlan.currentYear, GardenPlan.currentMonth);
            DatabaseManager.saveBed(bed);

            // go back to garden plan, refreshing the current plant plan
            GardenPlan.refreshBedAndGrid();
//                                            GardenPlan.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
            scene.stage.scene = GardenPlan.scene;
        } else {
           GartenplanerAlert.showAlert("Keinen Dünger selektiert.", scene);
        }
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
}

package var fertilizerList = bind loadFertilizerList(gute, schlechte, alle);

var listView : ListView = ListView {
    items: bind fertilizerList;
    vertical: true;
    layoutInfo: LayoutInfo {
        vfill: false;
        height: 350;
        minWidth: 400; maxWidth: 400; width: 400
    }
    onMouseClicked: function(me: MouseEvent) {
        if(me.clickCount >= 2) {
            // double click on a list item
            planFertilizer();
        }
    }
}

package var selectedFertilizer: FertilizerListViewItem = bind listView.selectedItem as FertilizerListViewItem on replace {
    visibleDesc = true;
    GartenplanerAlert.closeModalAlertPopup();
};
package var visibleDesc = false; // workaround to javafx not redrawing description label when updating plantlist after checkbox change

package var gute = true;
package var schlechte = false;
package var alle = false;

package var sceneNode : Node = VBox {
                layoutX: 100
                layoutY: 20
                content: [
                    HBox {
                        spacing: 20
                        content: [
                            VBox {
                                content: [
                                    Label {
                                        text: "Wählen Sie einen Dünger aus"
                                        styleClass: "gardenPlanerBlack"
                                    }
                                    listView,
                                    // check box boxes are not shown if using stylesheets, this is a known bug in javafx 1.3
                                    CheckBox {
                                        text: "gute Düngung (berücksichtigt Bodenbeschaffenheit im Beet)";
                                        selected: bind gute with inverse
                                    }
                                    CheckBox {
                                        text: "schlechte Düngung (berücksichtigt Bodenbeschaffenheit im Beet)";
                                        selected: bind schlechte with inverse
                                    }
                                    CheckBox {
                                        text: "alle";
                                        selected: bind alle with inverse
                                    }
                                    Label {
                                        text: "\nBemerkung: Falls eine Bodenbeschaffenheit einen Wert zwischen 40% und 60% hat,\nwird sie nicht berücksichtigt bei der Berechnung gut/schlecht.\n"
                                    }
                                ]
                            }
                            Label {
                                text: bind if (selectedFertilizer == null) then "-" else selectedFertilizer.fertilizer.getDescription();
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
                                text: "Düngung planen"
                                action: function() {
                                    planFertilizer();
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