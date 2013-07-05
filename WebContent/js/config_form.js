/*
 * CONFIG FORM LOGIC
 * 
 * Contains methods used by the configuration form.
 * Includes adding/removing visible levels, disabling restricted fields, etc.
 */

//formInit();

function formInit() {
	/* Initial form check.
	 * Hide all fields with no data entered, except the field immediately after current data entered.
	 */
	/*
	for(var i = 4; i <= 10; i++) {
		if (document.getElementsByName("Level_" + (i-1) + "_Points")[0].value == ""
		&&  document.getElementsByName("Level_" + (i) + "_Points")[0].value == "") {
			document.getElementById("Level_" + i).style.visibility = "hidden";
		} else {
			document.getElementById("Level_" + i).style.visibility = "visible";
		}
	}
	checkForm();
	*/
}

function addLevel() {
	/*
	 * Shows the next available hidden level.
	 */
	for(var i = 4; i <= 10; i++) {
		if(document.getElementById("Level_" + i).style.visibility == "hidden") {
			document.getElementById("Level_" + i).style.visibility = "visible";
			return;
		}
	}
}

function subtractLevel() {
	/*
	 * Hides the last available visible level.
	 */
	for(var i = 10; i >= 4; i--) {
		if(document.getElementById("Level_" + i).style.visibility == "visible") {
			document.getElementById("Level_" + i).style.visibility = "hidden";
			return;
		}
	}
}

function clearForm() {
	/*
	 * Clears all data currently entered in the form.
	 */
	for(var i = 1; i <= 10; i++) {
			document.getElementsByName("Level_" + i + "_Points")[0].value = "";
	}
	checkForm();
}

function resetForm() {
	/*
	 * Resets all data to previously entered values.
	 */
	for(var i = 1; i <= 10; i++) {
		document.getElementsByName("Level_" + i + "_Points")[0].value = 
		document.getElementsByName("Level_" + i + "_Points")[0].defaultValue;
		if(document.getElementsByName("Level_" + i + "_Points")[0].value != "") {
			document.getElementById("Level_" + i).style.visibility == "visible";
			if (i < 10) {document.getElementById("Level_" + (i+1)).style.visibility == "visible";}
		}
	}
	checkForm();
}

function checkForm() {
	/*
	 * Disable all fields except those that already have data, and the field immediately following the last level entered.
	 */
	for(var i = 2; i <= 10; i++) {
		if(document.getElementsByName("Level_" + (i-1) + "_Points")[0].value == "" 
		|| document.getElementsByName("Level_" + (i-1) + "_Points")[0].disabled) {
			document.getElementsByName("Level_" + i + "_Points")[0].disabled = true;
		} else {
			document.getElementsByName("Level_" + i + "_Points")[0].disabled = false;
		}
	}
}