<!-- 
	Gamegogy Leaderboard 1.0
    Copyright (C) 2012  David Thornton

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
<bbData:context id="ctx">  <!-- to allow access to the session variables -->
<%

	//create a student class to hold their grades and other info
	final class Student implements Comparable<Student> {
	    public Double score;
	    public String username;
	    
	    public Student(String username, Double score) {
	        this.score = score;
	        this.username = username;
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
				students.add(new Student(cm.getUser().getUserName(), currScore));
			}		
		}
		index = index + 1;
	}
	Collections.sort(students);
	Collections.reverse(students);

	String jsPath = PlugInUtil.getUri("dt", "gamegogyleaderboard1.0", "js/highcharts.js");
%>

<!DOCTYPE HTML>
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
		<title>Vital Statistics</title>
		
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
		<script type="text/javascript" src=<%=jsPath%>></script>
		
		<script type="text/javascript">		
			jQueryAlias = $.noConflict();  //to avoid this webapp conflicting with others on the page
		                                                   
			jQueryAlias(document).ready(function() {			
				var gamegogyLeaderboardChart;			
				
				var seriesValues = [
   				<%	
   					boolean alreadyHighlighted = false;
   					for (int x = 0; x < students.size(); x++){
   						Double score = (Double) students.get(x).score;
   						if (score == scoreToHighlight && !alreadyHighlighted) {
   							alreadyHighlighted = true;
   							out.print("{ y: " + score.toString() + ", color: '#008844'}");
   						}
   						else {
   							out.print(score.toString());
   						}
   						if (x < students.size() -1) { out.print(","); }
   						else { out.print("];"); }
   					}
   				%>
   				
   				var studentNames = [
  				<%	
  					if (isUserAnInstructor) {
  						for (int x = 0; x < students.size(); x++){
	  						String username = (String) students.get(x).username;
	  						out.print('"' + username + '"');   						
	  						if (x < students.size() -1) { out.print(","); }
	  						else { out.print("];"); }
	  					}
  					}
  				
  					else {
  						// this is a kludge
  						out.print("1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50];");
  					}
  				%>
		
				
				gamegogyLeaderboardChart = new Highcharts.Chart({
					chart: {
						renderTo: 'chartContainer',
						type: 'bar'
					},
					legend: {  enabled: false  },  
					title: {
						text: 'Leaderboard'
					},					
					xAxis: {						
						categories: studentNames,
						title: {
							text: "Player"
						}
					},
					yAxis: {
						title: {
							text: 'XP'
						},
						gridLineWidth: 0
					},
					tooltip: {
						formatter: function() {
							var level = 1;
							// literals here!
							if (this.y < 100) { level = 1; }
							else if (this.y < 300) { level = 2; }
							else if (this.y < 600) { level = 3; }
							else if (this.y < 1000) { level = 4; }
							else { level = 5; }
							return "level: " + level;
						}
					},
					plotOptions: {
						bar: {
							dataLabels: {
								enabled: true
							}
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
	
			});  //end of function	
		</script>      
		
	</head>
	<body>
		<div id="chartContainer"></div>			
	</body>
</html>
</bbData:context>