/*
 	LoadGarden.fx

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
import javafx.scene.layout.VBox;
import javafx.scene.control.ListView;
import ch.ergon.gartenplaner.entity.data.Garden;
import ch.ergon.gartenplaner.entity.DatabaseManager;
import javafx.scene.layout.LayoutInfo;
import javafx.scene.layout.HBox;
import javafx.scene.control.Button;
import javafx.scene.paint.Color;
import javafx.scene.control.Label;
import javafx.stage.Alert;
import java.lang.Error;
import java.lang.RuntimeException;
import ch.ergon.gartenplaner.app.GartenplanerConstants;
import javafx.scene.input.MouseEvent;

/**
 * Garten laden Maske.
 * @author albin
 */
package class GardenListViewItem {
    package var garden: Garden;
    public override function toString() {
        // the string to be displayed in the choice list in the mask
        garden.toString();
    }

}

package function loadGardenList() : GardenListViewItem[] {
    GartenplanerConfirm.closeModalConfirmPopup(); // workaround for javafx not providing a nice popup solution
    GartenplanerAlert.closeModalAlertPopup();
    
    var col  = DatabaseManager.getGardens();
    for(g in col) {
        GardenListViewItem {
            garden: g
        }
    }
}

package var gardenList = loadGardenList();

function loadGarden() : Void {
    try {
        if(selectedGarden != null) {
            GardenPlan.refreshAll();

            // starting with no bed selected
            BedRectangle.currentBed = null;
            if(BedRectangle.currentBedRectangle != null) {
                // if loading same garden again, the current rectangle should have an unselected color
                BedRectangle.currentBedRectangle.color = Color.rgb(60, 30, 10);
            }
            BedRectangle.currentBedRectangle = null;
            scene.stage.scene = GardenPlan.scene;
//                                            GardenPlan.fadeintransition.playFromStart();// does not work properly, sometimes show first fully and then start to fadein
        }
     } catch (t: RuntimeException){
        Alert.inform("FATAL", "Ein unerwarteter RuntimeException ist aufgetreten: {t}");
     } catch (t: Error){
        Alert.inform("FATAL", "Ein unerwarteter Fehler ist aufgetreten: {t}");
     } // cannot catch Throwable, because javafx often throws NonLocalReturnException
}

var listView : ListView = ListView {
    items: bind gardenList;
    vertical: true;
    layoutInfo: LayoutInfo {
        vfill: false;
        height: 400;
        minWidth: 400; maxWidth: 400; width: 400
    }
    onMouseClicked: function(me: MouseEvent) {
        if(me.clickCount >= 2) {
            // double click on a list item
            loadGarden();
        }
    }
}

package var selectedGarden: GardenListViewItem = bind listView.selectedItem as GardenListViewItem;

package var scene: Scene = Scene {
        width: GartenplanerConstants.SCENE_WIDTH
        height: GartenplanerConstants.SCENE_HEIGHT
        fill: Color.rgb(125, 180, 100) // a nice light green. wanted black, but checkboxes don't work with stylesheets, so no white text possible
        stylesheets: [ "{__DIR__}GartenPlaner.css" ]
        content: [
            VBox {
                layoutX: 100;
                layoutY: 20;
                content: [
                    Label {
                        text: "Gespeicherte Garten"
                        styleClass: "gardenPlanerBlack"
                    }
                    listView,
                    HBox {
                        content: [
                            Button {
                                text: "Zurück"
                                action: function() {
                                    scene.stage.scene = Entrance.scene;
                                }
                            }
                            Button {
                                text: "Laden"
                                action: function() {
                                    GartenplanerConfirm.closeModalConfirmPopup(); // workaround for javafx not providing a nice popup solution
                                    GartenplanerAlert.closeModalAlertPopup();
                                    if(selectedGarden == null) {
                                        GartenplanerAlert.showAlert("Kein Garten gewählt zum Laden.", scene);
                                    } else {
                                        loadGarden();
                                    }
                                }
                            }
                            Button {
                                text: "Löschen"
                                action: function() {
                                    try {
                                        GartenplanerConfirm.closeModalConfirmPopup(); // workaround for javafx not providing a nice popup solution
                                        GartenplanerAlert.closeModalAlertPopup();
                                        if(selectedGarden != null) {
                                            GartenplanerConfirm.showConfirm("Wollen Sie den Garten wirklich löschen?", scene, deleteGarden);
                                        } else {
                                            GartenplanerAlert.showAlert("Kein Garten gewählt zum Löschen.", scene);
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

/*
* callback function
*/
function deleteGarden() : Void {
    DatabaseManager.deleteGarden(selectedGarden.garden);
    gardenList = loadGardenList();  // refresh list after delete
}
