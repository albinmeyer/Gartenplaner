/*
 	FxMainLauncher.java

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

package ch.ergon.gartenplaner.main;

import com.sun.javafx.runtime.Main;

/**
 * When starting the application through a "normal" java runtime (java.exe), and not
 * through javafx-sdk (javafx.exe), we need a main method in a java class,
 * and this main method calls the main method of the javafx runtime, with
 * the starting java-fx-file as argument.
 * @author albin
 */
public class FxMainLauncher {
    public static void main(String[] args) throws Exception {
        String javaVersion = System.getProperty("java.version");
        String osName = System.getProperty("os.name");
        if(osName.indexOf("Windows") < 0 && osName.indexOf("Mac") < 0) {
            System.out.println("Falsche OS Version. Gefunden: " + osName + "; benÃ¶tigt: Windows oder Mac");
        } else if(!javaVersion.startsWith("1.6.0") && !javaVersion.startsWith("1.7.0")) {
            System.out.println("Falsche Javaversion. Gefunden: " + javaVersion + "; benötigt: 1.6.0_* oder 1.7.0_*");
        } else {
            // everything ok, start the javafx app
            Main.main(new String[] {"ch.ergon.gartenplaner.gui.Main"});
        }
    }
}