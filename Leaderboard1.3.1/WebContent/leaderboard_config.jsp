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
<%@ taglib prefix="bbUI" uri="/bbUI" %>
<%@page import="blackboard.servlet.data.MultiSelectBean"%>


<%@page import="com.spvsoftwareproducts.blackboard.utils.B2Context"%>
<bbNG:modulePage type="personalize" ctxId="ctx">
<%
	String color_value = "";
	String user_color_value = "";
	Id courseID = ctx.getCourseId();
	String [] level_values = new String[10];
	String [] level_labels = new String[10];
	String jsConfigFormPath = PlugInUtil.getUri("dt", "leaderboardblock11", "js/config_form.js");
	
		
	// Create a new persistence object.  Don't save empty fields.
	B2Context b2Context = new B2Context(request);
	b2Context.setSaveEmptyValues(false);
	
	// Grab previously saved color value
	color_value = b2Context.getSetting(true, false, "color");
	user_color_value = b2Context.getSetting(true, false, "user_color");
	
	// Grab previously saved level values and labels
	for(int i = 0; i < 10; i++){
		level_values[i] = b2Context.getSetting(false, true, "Level_" + (i+1) + "_Points" + courseID.toExternalString() );
		level_labels[i] = b2Context.getSetting(false, true, "Level_" + (i+1) + "_Labels" + courseID.toExternalString());
	}
%>

<%@include file="leaderboard_student.jsp" %>

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
						<bbNG:elementInstructions text="Select a general plotband color."/>
						<bbNG:colorPicker name="color" initialColor="<%= color_value %>"/>
					</bbNG:dataElement>
				</bbNG:step>
			
				<bbNG:step title="Plotbands Points">
					<bbNG:dataElement>
						<bbNG:elementInstructions text="Set point requirements for each level. Everyone starts at Level 1. Note: Higher levels are not shown on the leaderboard until at least one student reaches that level." />
						<table>
							<!-- Fill up table with 10 levels.  Includes label & input field -->
							<tr>
								<th></th>
								<th style="text-align:center;"> Points Required</th>
								<th style="text-align:center;">Title</th>
							</tr>
							<% for(int i = 2; i <= 10; i++) { 
								//Sets default level titles
								String levelLabel;
								String levelPoints;
								levelLabel = level_labels[i-1];
								levelPoints = level_values[i-1];
								//Sets some default values if none is set
								if(i == 2 && levelLabel.equals("") && levelPoints.equals("")) {
									levelLabel = "Apprentice";
									levelPoints = "100";
								}
								if(i == 3 && levelLabel.equals("") && levelPoints.equals("")) {
									levelLabel = "Journeyman";
									levelPoints = "300";
								}
								if(i == 4 && levelLabel.equals("") && levelPoints.equals("")) {
									levelLabel = "Master Craftsman";
									levelPoints = "700";
								}
								if(i == 5 && levelLabel.equals("") && levelPoints.equals("")) {
									levelLabel = "Grand Master";
									levelPoints = "1000";
								}
								
							%>
								<tr id="Level_<%= i %>">
									<td>Level <%= i %> </td>
									<input type="hidden" name="courseID" value="<%= courseID.toExternalString() %>" /> <!--Have to use toExternalString() to get the courseID Key ;Used to pass the CourseID to leaderboard_save.jsp   -->
									<td><input type="text" name="Level_<%= i %>_Points" size="12" value="<%=levelPoints%>" onkeyup="checkForm()"/></td>
									<td><input type="text" name="Level_<%= i %>_Labels" size="18" value="<%=levelLabel%> " /></td>
								</tr>
								
							<% } %>
						</table>
						<!-- Javascript Form Logic //-->
						<script type="text/javascript" src="<%= jsConfigFormPath %>"></script>
					</bbNG:dataElement>
				</bbNG:step>
				
				<!-- Show/Hide Student Selection-->	
				<bbNG:step title="Show/Hide Students">
				<% 
				/*
				Started by Zack White.
				Last edit 3-9-14 by Tim Burch.
				*/
				B2Context b2Context_sh = new B2Context(request);
				b2Context_sh.setSaveEmptyValues(false);
				List<MultiSelectBean> leftList = new ArrayList<MultiSelectBean>();
				List<MultiSelectBean> rightList = new ArrayList<MultiSelectBean>();
				String modified = b2Context_sh.getSetting(false, true, "modified" +  courseID.toExternalString());
				List<CourseMembership> cmlist = CourseMembershipDbLoader.Default.getInstance().loadByCourseIdAndRole(courseID, CourseMembership.Role.STUDENT, null, true);
				
				if(modified.equals("true")){//A save file already exists.
					String visibleList = b2Context_sh.getSetting(false, true, "visibleStudents" +  courseID.toExternalString());
					String[] visibleArr = visibleList.split(",");
					if(!(visibleList.trim().equals(" ")) && !(visibleList.trim().isEmpty()) && visibleList != null){
						for(int i = 0; i < visibleArr.length; i++){//Add any saved visible to left side.
							MultiSelectBean leftBean = new MultiSelectBean();
							leftBean.setValue(visibleArr[i]);
							leftBean.setLabel(visibleArr[i]);
							leftList.add(leftBean);
						}
					}
					String hiddenList = b2Context_sh.getSetting(false, true, "hiddenStudents" +  courseID.toExternalString());
					String[] hiddenArr = hiddenList.split(",");
					if(!(hiddenList.trim().equals(" ")) && !(hiddenList.trim().isEmpty()) && hiddenList != null){
						for(int i = 0; i < hiddenArr.length; i++){//Add any saved hidden to right side.
							MultiSelectBean rightBean = new MultiSelectBean();
							rightBean.setValue(hiddenArr[i]);
							rightBean.setLabel(hiddenArr[i]);
							rightList.add(rightBean);
						}
					}
					/*
					If the cmlist (entire course roster) is larger than both the hidden and visible lists, then
					a student must be missing from the lists. So this checks if any new student has been added
					to the course roster since Leaderboard has been uploaded.
					*/
					//if(cmlist.size() > (visibleList.length() + hiddenList.length())){
						for(int i = 0; i < cmlist.size(); i++){//Check entire roster.
							User student = cmlist.get(i).getUser();
							String stuName = student.getGivenName() + " " + student.getFamilyName() + ": " + student.getUserName();
							boolean found = false;
							for(int j = 0; j < visibleArr.length; j++){//Check visible list
								if(stuName.equals(visibleArr[j])){
									found = true;
									break;
								}
							}
							if(found == false){
								for(int j = 0; j < hiddenArr.length; j++){//Check hidden list
									if(stuName.equals(hiddenArr[j])){
										found = true;
										break;
									}
								}
							}
							if(found == false){//If the name wasn't found on either list, add to visible.
								MultiSelectBean leftBean = new MultiSelectBean();
								leftBean.setValue(stuName);
								leftBean.setLabel(stuName);
								leftList.add(leftBean);
							}
						}
					}// end of check for newly added student
				//}// end of if a save file already exists
				else{//Set default with everyone visible since lists haven't been created yet.
					for(int i = 0; i < cmlist.size(); i ++){
						MultiSelectBean leftBean = new MultiSelectBean();
						User student = cmlist.get(i).getUser();
						leftBean.setValue(student.getGivenName() + " " + student.getFamilyName() + ": " + student.getUserName());
						leftBean.setLabel(student.getGivenName() + " " + student.getFamilyName() + ": " + student.getUserName());
						leftList.add(leftBean);
					}
				}
				

				%>
				
					<bbUI:multiSelect widgetName="show_n_hide" leftCollection="<%=leftList%>" rightCollection="<%=rightList%>" formName="container_form" leftTitle = "Visible Students" rightTitle = "Hidden Students"/>
				</bbNG:step>
				
				<!-- Grade Column Chooser -->
				<%
					for(int i = 0; i < 10; i++){
						level_values[i] = b2Context.getSetting(false, true, "Level_" + (i+1) + "_Points" + courseID.toExternalString() );
						level_labels[i] = b2Context.getSetting(false, true, "Level_" + (i+1) + "_Labels" + courseID.toExternalString());
					}
					
					// use the GradebookManager to get the gradebook data
					GradebookManager gm = GradebookManagerFactory.getInstanceWithoutSecurityCheck();
					BookData bookData = gm.getBookData(new BookDataRequest(courseID));
					List<GradableItem> lgm = gm.getGradebookItems(courseID);
					// it is necessary to execute these two methods to obtain calculated students and extended grade data
					bookData.addParentReferences();
					bookData.runCumulativeGrading();
						
					// create list of grade columns
					String[] gradeList = new String[lgm.size()];
					for (int i = 0; i < lgm.size(); i++) {
						GradableItem gi = (GradableItem) lgm.get(i);
						gradeList[i] = gi.getTitle();
					}
					
					// load previous grade column choice. Sets default column as "Total". 
					String prev_grade_choice = "Total";
					String prev_grade_string = "";
					B2Context b2Context_grade = new B2Context(request);
					prev_grade_choice = b2Context_grade.getSetting(false,true,"gradebook_column" + courseID.toExternalString());
					if(prev_grade_choice == "") prev_grade_choice = "Total";
					prev_grade_string = prev_grade_choice + " - (Chosen)"; //selected option on dropdown list 
				%>
				<bbNG:step title="Choose Grade Column">
					 <bbNG:dataElement>
					 	<bbNG:elementInstructions text=" Choose Grade column to be used." />
				        <bbNG:selectElement name="gradebook_column"  multiple= "false" >
				        	
				   				<bbNG:selectOptionElement value="<%= prev_grade_choice %>" optionLabel="<%= prev_grade_string %>" />
				        	<% for(int i = 0; i < lgm.size(); i++) { 
				        		String gradeItem = gradeList[i]; 
				        		if(!gradeItem.equals(prev_grade_choice)) {%>
				        		 <bbNG:selectOptionElement value="<%= gradeItem %>" optionLabel="<%= gradeItem %>"/>
				        	<% } 
				        	} %>
				        </bbNG:selectElement>
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
