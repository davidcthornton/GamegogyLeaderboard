<%
final class Student implements Comparable<Student> {
    public Double score;
    public String firstName;
    public String lastName;
    private boolean hidden;
    
    public Student(String firstName, String lastName, Double score) {
        this.score = score;
        this.firstName = firstName;
        this.lastName = lastName;
        this.hidden = false;
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
    public void setHidden(boolean hidden) {
    	this.hidden = hidden;
    }
    
    public boolean getHidden() {
    	return this.hidden;
    }
} //end of class Student
%>