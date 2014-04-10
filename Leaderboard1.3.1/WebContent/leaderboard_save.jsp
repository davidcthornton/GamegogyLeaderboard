<%@page import="blackboard.base.*"%>
<%@page import="blackboard.data.course.*"%> 				<!-- for reading data -->
<%@page import="blackboard.data.user.*"%> 					<!-- for reading data -->
<%@page import="blackboard.persist.*"%> 					<!-- for writing data -->
<%@page import="blackboard.persist.course.*"%> 				<!-- for writing data -->
<%@page import="blackboard.platform.gradebook2.*"%>
<%@page import="blackboard.platform.gradebook2.impl.*"%>
<%@page import="java.util.*"%> 								<!-- for utilities -->
<%@page import="blackboard.platform.plugin.PlugInUtil"%>	<!-- for utilities -->
<%@ taglib uri="/bbData" prefix="bbData"%> 					<!-- for tags -->
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%@page import="com.spvsoftwareproducts.blackboard.utils.B2Context"%>
<%@page import="blackboard.servlet.data.MultiSelectBean"%>

<%
String s = "<script>history.go(-2);</script>";

if (request.getMethod().equalsIgnoreCase("POST")) {
	
	if(request.getParameter("instructor").equals("true")) {
		// Create a new persistence object for course settings.  Don't save empty fields.
		B2Context b2Context_c = new B2Context(request);
		b2Context_c.setSaveEmptyValues(false);
		
		int numFilledLevels = 10;
		String setting = "";
		String levelLabel =""; //ADDED 09/27/2013
		String courseID = request.getParameter("courseID"); //Gets courseID that was passed from leaderboard_config.jsp -JJL
		// Get level values from user-submitted data and add it to the persistence object.
		
		for(int i = 1; i <= 10; i++) {
			setting = (i == 1)? "0":request.getParameter("Level_" + i + "_Points");
			levelLabel = (i == 1)? "0":request.getParameter("Level_" + i + "_Labels"); //ADDED 09/27/2013
			
			b2Context_c.setSetting(false, true, "Level_" + i + "_Points" + courseID, setting);
			b2Context_c.setSetting(false, true, "Level_" + i + "_Labels" + courseID, levelLabel); //ADDED 09/27/2013
			//Count the number of levels by subtracting empty strings from total available levels.
			if(setting == ""){numFilledLevels--;}
		}
		
		//Add number of levels key-pair to the persistence object.
		b2Context_c.setSetting(false,true,"num_filled_levels" + courseID,Integer.toString(numFilledLevels)); //Added courseID to num_filled to fix couse overide bug -JJL
		
		//Get gradebook column value from user-submitted data and add it to the persistence object.
		String gradeLabel=  b2Context_c.getRequestParameter("gradebook_column", "").trim();
		b2Context_c.setSetting(false, true, "gradebook_column" + courseID, gradeLabel);

		//Show/hide settings Last edit 3-9-14 by Tim Burch.
		String leftVals = (request.getParameter("show_n_hide_left_values")).trim();
		String rightVals = (request.getParameter("show_n_hide_right_values")).trim();
		b2Context_c.setSetting(false, true, "visibleStudents" + courseID, leftVals);
		b2Context_c.setSetting(false, true, "hiddenStudents" + courseID, rightVals);
		b2Context_c.setSetting(false, true, "modified" + courseID, "true");
		
		//Parse leftVals string to get number of students (commas)
		int numCommas = 0;
		if(leftVals.length() > 0){
			char[] studentCharArray = leftVals.toCharArray();
			for(char c : studentCharArray){
				if(c == ','){
					numCommas += 1;
				}
			}
			numCommas += 1;//For example if you have only one student, there wouldn't be a comma.
		}
		
		//Number of visible students.
		b2Context_c.setSetting(false, true, "numVisibleStudents" + courseID, Integer.toString(numCommas));
		
		// Save course settings
		b2Context_c.persistSettings(false, true);
	}
	
	// New persistence object for user-specific settings
	B2Context b2Context_u = new B2Context(request);
	
	// Get color value from user-submitted data and add it to the persistence object.
	b2Context_u.setSetting(true, false, "color", request.getParameter("color"));
	b2Context_u.setSetting(true, false, "user_color", request.getParameter("user_color"));
	
	// Save the settings (USER-SPECIFIC)
	b2Context_u.persistSettings(true, false);
}

// May need error checking logic here (gaps in level fields, overlapping values, etc.)


%>

<%=s %>