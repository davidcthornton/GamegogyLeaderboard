<!--

	Gamegogy Leaderboard 1.1
    Copyright (C) 2013  David Thornton

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-->

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
<bbNG:includedPage ctxId="ctx">

	<%
		//create a student class to hold their grades and other information
		final class Student implements Comparable<Student> {
		    public Double score;
		    public String firstName;
		    public String lastName;
		    
		    public Student(String firstName, String lastName, Double score) {
		        this.score = score;
		        this.firstName = firstName;
		        this.lastName = lastName;
		    }
		    
		    public int compareTo(Student s) {
		    	if (this.score > s.score) {
		    		return 1;
		    	}
		    	else if (this.score < s.score) {
		    		return -1;
		    	}
		    	else { return 0; }	    	
		    }
		} //end of class Student
		
		// get the current user
		User sessionUser = ctx.getUser();
		Id courseID = ctx.getCourseId();		
		String sessionUserRole = ctx.getCourseMembership().getRoleAsString();	
		String sessionUserID = sessionUser.getId().toString();
		
		// use the GradebookManager to get the gradebook data
		GradebookManager gm = GradebookManagerFactory.getInstanceWithoutSecurityCheck();
		BookData bookData = gm.getBookData(new BookDataRequest(courseID));
		List<GradableItem> lgm = gm.getGradebookItems(courseID);
		// it is necessary to execute these two methods to obtain calculated students and extended grade data
		bookData.addParentReferences();
		bookData.runCumulativeGrading();
		// get a list of all the students in the class
		List <CourseMembership> cmlist = CourseMembershipDbLoader.Default.getInstance().loadByCourseIdAndRole(courseID, CourseMembership.Role.STUDENT, null, true);
		Iterator<CourseMembership> i = cmlist.iterator();
		List<Student> students = new ArrayList<Student>();
		
		// instructors will see student names
		boolean isUserAnInstructor = false;
		if (sessionUserRole.trim().toLowerCase().equals("instructor")) {
			isUserAnInstructor = true;
		}	
		Double scoreToHighlight = -1.0;
		int index = 0;
		
		while (i.hasNext()) {	
			CourseMembership cm = (CourseMembership) i.next();
			String currentUserID = cm.getUserId().toString();
			
			for (int x = 0; x < lgm.size(); x++){			
				GradableItem gi = (GradableItem) lgm.get(x);					
				GradeWithAttemptScore gwas2 = bookData.get(cm.getId(), gi.getId());
				Double currScore = 0.0;	
				
				if(gwas2 != null && !gwas2.isNullGrade()) {
					currScore = gwas2.getScoreValue();	 
				}						
				if (gi.getTitle().trim().toLowerCase().equalsIgnoreCase("total")) {
					if (sessionUserID.equals(currentUserID)) {
						scoreToHighlight = currScore;
					}
					students.add(new Student(cm.getUser().getGivenName(), cm.getUser().getFamilyName(), currScore));
				}		
			}
			index = index + 1;
		}
		Collections.sort(students);
		Collections.reverse(students);
	
		String jQueryPath = PlugInUtil.getUri("dt", "leaderboardblock11", "js/jqueryNoConflict.js");
		String highChartsPath = PlugInUtil.getUri("dt", "leaderboardblock11", "js/highcharts.js");		
	%>		
	
		<script type="text/javascript">		
			// this is a rather kludgy fix for a bug introduced by Blackboard 9.1 SP 10.  It ensures that javascript files are loaded in the correct order, instead of haphazardly.
			<jsp:include page="js/jqueryNoConflict.js" />
			<jsp:include page="js/highcharts.js" />
			
	        dave(document).ready(function() {
	
				var gamegogyLeaderboardChart;			
				
				var seriesValues = [
	  				<%	
	  					// Load saved color settings
	  					B2Context b2Context = new B2Context(request);
	  					String user_color = b2Context.getSetting(true, false, "user_color");	// Highlight color
	  					String color = b2Context.getSetting(true, false, "color");				// General color
	  					if(user_color == "") user_color = "#44aa22";
	  					if(color == "") color = "#4572A7";
	  				
	  					boolean alreadyHighlighted = false;
	  					for (int x = 0; x < students.size(); x++){
	  						Double score = (Double) students.get(x).score;
	  						if (score == scoreToHighlight && !alreadyHighlighted) {
	  							alreadyHighlighted = true;
	  							out.print("{dataLabels: { enabled: true, style: {fontWeight: 'bold'} }, y:  " + score.toString() + ", color: '"+ user_color + "'}");
	  						}
	  						else {
	  							out.print("{y: " + score.toString() + ", color: '" + color + "'}");
	  						}
	  						if (x < students.size() -1) { out.print(","); }
	  						else { out.print("];"); }
	  					}
	  				%>
	  				
	  				var studentNames = [
	 				<%	
	 					if (isUserAnInstructor) {
	 						for (int x = 0; x < students.size(); x++){
	  						String firstName = (String) students.get(x).firstName;
	  						String lastName = (String) students.get(x).lastName;
	  						out.print('"' + firstName.substring(0, 1) + ' ' + lastName + '"');   						
	  						if (x < students.size() -1) { out.print(","); }
	  						else { out.print("];"); }
	  					}
	 					}	  				
	 					else {
	 						// this is a remote kludge
	 						out.print("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50];");
	 					}
	 				%>
		
				
	 				gamegogyLeaderboardChart = new Highcharts.Chart({
					chart: {
						renderTo: 'leaderboardBlockChartContainer',
						type: 'bar'
					},
	                   plotOptions: {
	                       series: {
							pointPadding: 0,
							groupPadding: 0.1,
	                           borderWidth: 0,
	                           borderColor: 'gray',
	                           shadow: false
	                       }
	                   },
					legend: {  enabled: false  },  
					title: {
						text: null
					},						
					xAxis: {						
						categories: studentNames,
						title: {
							text: null
						}
					},
					yAxis: {
						title: {
							text: null
						},
						gridLineWidth: 0,
						labels: {
							enabled: false
						},
						offset: 20,
						plotBands: [
							<%
							//Capture the number of levels as it was saved in the persistence object by leaderboard_save.jsp.
							String s =  b2Context.getSetting(false,true,"num_filled_levels");
							int filledLevels = (s == "")? 0: Integer.parseInt(s);
							
							int levelFrom = 0;
							int levelTo = 0;
							
							//For each level where a custom value was provided...
							for(int j = 1; j<=filledLevels; j++){
								//Gather the target value to achieve the current level from the persistence object.
								levelFrom = Integer.parseInt(b2Context.getSetting(false,true,"Level_" + (j) + "_Points"));
								if(j == filledLevels) {
									levelTo = levelFrom * 2;
								} else {
									levelTo = Integer.parseInt(b2Context.getSetting(false,true,"Level_" + (j+1) + "_Points"));
								}
								//Calculate the correct gradient color using RGB and dividing with respect to filledLevels.
								int gradient = (255/(filledLevels+10))*((filledLevels+10)-j);
								
								//Output javascript for each highchart plotband.
								out.print("{ color: 'rgb("+gradient+", "+gradient+", "+gradient+")', ");
								out.print("from: "+levelFrom+", ");
								out.print("to: "+levelTo+", ");
								if (j == 1) out.print("label: { text: '', verticalAlign: 'bottom', style: { color: '#666666'}}}");
								else out.print("label: { text: 'LvL "+j+"', verticalAlign: 'bottom', style: { color: '#666666'}}}");
								//Add commas after plotband elements until the last element which does not need one.
								if(j<filledLevels){out.print(",");}
							}
							%>
						]
					
					},
					tooltip: {
						formatter: function() {
							return this.y;
						}
					},
					
					credits: {
						enabled: false
					},
					series: [{
						name: 'XP',
						data: seriesValues
					}]
				}); //end of chart
			}); // end of ready function									  		
		</script>	
	<div id="leaderboardBlockChartContainer"></div>
</bbNG:includedPage>