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
	String color_value = "";
	String user_color_value = "";
	String [] level_values = new String[10];
	String jsConfigFormPath = PlugInUtil.getUri("dt", "leaderboardblock11", "js/config_form.js");
		
	// Create a new persistence object.  Don't save empty fields.
	B2Context b2Context = new B2Context(request);
	b2Context.setSaveEmptyValues(false);
	
	// Grab previously saved color value
	color_value = b2Context.getSetting(true, false, "color");
	user_color_value = b2Context.getSetting(true, false, "user_color");
	
	// Grab previously saved level values
	for(int i = 0; i < 10; i++){
		level_values[i] = b2Context.getSetting(false, true, "Level_" + (i+1) + "_Points");
	}
%>

<bbNG:modulePage type="personalize" ctxId="ctx">
<bbNG:pageHeader>
	<bbNG:pageTitleBar title="Leaderboard Configuration"></bbNG:pageTitleBar>
</bbNG:pageHeader>

<!-- Body Content: Plotbands & Color Picker -->
<bbNG:form action="leaderboard_save.jsp" method="post" name="plotband_config_form" id="plotband_config_form" onSubmit="return validateForm()">
	<bbNG:dataCollection>
		
			<%	
				// get the current user's information
				String sessionUserRole = ctx.getCourseMembership().getRoleAsString();
				boolean isUserAnInstructor = false;
				if (sessionUserRole.trim().toLowerCase().equals("instructor")) {
					isUserAnInstructor = true;
				}	
			%>
			
			<!-- Instructor flag submitted to save page - MAY BE UNSAFE -->
			<input type="hidden" name="instructor" value="<%= isUserAnInstructor %>" />
			
			<!-- Plotbands Configuration Form -->
			<% if (isUserAnInstructor) { %>
				<!-- Color Picker -->
				<bbNG:step title="Primary Bar Color">
					<bbNG:dataElement>
						<bbNG:colorPicker name="color" initialColor="<%= color_value %>" helpText="Select a general plotband color."/>
					</bbNG:dataElement>
				</bbNG:step>
			
				<bbNG:step title="Plotbands Points">
					<bbNG:dataElement>
						<bbNG:elementInstructions text="Set point requirements for each level. Everyone starts at Level 1. Note: Higher levels are not shown on the leaderboard until at least one student reaches that level." />
						<table>
							<!-- Fill up table with 10 levels.  Includes label & input field -->
							<% for(int i = 2; i <= 10; i++) { %>
								<tr id="Level_<%= i %>">
									<td>Level <%= i %> -</td>
									<td><input type="text" name="Level_<%= i %>_Points" size="3" value="<%=level_values[i-1]%>" onkeyup="checkForm()"/></td>
								</tr>
							<% } %>
						</table>
						<!--
						<input id="popLevel_button" type="button" value="-" onclick="subtractLevel()" />
						<input id="pushLevel_button" type="button" value="+" onclick="addLevel()" />
						<input type="button" value="Reset" onclick="resetForm()" />
						<input type="button" value="Clear" onclick="clearForm()" />
						-->
						<!-- Javascript Form Logic //-->
						<script type="text/javascript" src="<%= jsConfigFormPath %>"></script>
					</bbNG:dataElement>
				</bbNG:step>
			<% } else { %>
				<!-- Color Picker -->
				<bbNG:step title="Everyone else's color">
					<bbNG:dataElement>
						<bbNG:colorPicker name="color" initialColor="<%= color_value %>" helpText="Select a general plotband color."/>
					</bbNG:dataElement>
				</bbNG:step>
				<bbNG:step title="Your bar's color">
					<bbNG:dataElement>
						<bbNG:colorPicker name="user_color" initialColor="<%= user_color_value %>" helpText="Choose a color for your own bar."/>
					</bbNG:dataElement>
				</bbNG:step>
			<% } %>
		<bbNG:stepSubmit />
	</bbNG:dataCollection>
</bbNG:form>
</bbNG:modulePage>
