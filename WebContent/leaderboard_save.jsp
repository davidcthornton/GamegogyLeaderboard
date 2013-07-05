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

<%
String s = "<script>history.go(-2);</script>";

if (request.getMethod().equalsIgnoreCase("POST")) {
	
	if(request.getParameter("instructor").equals("true")) {
		// Create a new persistence object for course settings.  Don't save empty fields.
		B2Context b2Context_c = new B2Context(request);
		b2Context_c.setSaveEmptyValues(false);
		
		int numFilledLevels = 10;
		String setting = "";
		// Get level values from user-submitted data and add it to the persistence object.
		for(int i = 1; i <= 10; i++) {
			setting = (i == 1)? "0":request.getParameter("Level_" + i + "_Points");
			b2Context_c.setSetting(false, true, "Level_" + i + "_Points", setting);
			//Count the number of levels by subtracting empty strings from total available levels.
			if(setting == ""){numFilledLevels--;}
		}
		
		//Add number of levels key-pair to the persistence object.
		b2Context_c.setSetting(false,true,"num_filled_levels",Integer.toString(numFilledLevels));
		
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