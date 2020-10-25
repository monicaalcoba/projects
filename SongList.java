package cmsc256;
import bridges.connect.Bridges;
import bridges.connect.DataSource;
import bridges.data_src_dependent.ActorMovieIMDB;
import bridges.data_src_dependent.Song;
import java.util.List;
import java.util.Scanner;
import java.util.Collections;

/**
 *  SongList program
 *  Alcoba-Flores, Monica
 *  Project 3
 *  CMSC 256 Fall 2019, Section 002
 *  September 29, 2019
 *  
 *  This program reads in song data from the Bridges API and asks the user 
 *  for an artist name to output a formatted list of all the songs by that 
 *  artist that appear on the playlist, grouped by album and in alphabetical 
 *  order by song title. 
 */

public class SongList {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
			
		SongList s = new SongList(); // create an object of songList 
		
		Bridges bridges = new Bridges(5, "alcobafloresm", "1181206373013");
		DataSource ds = bridges.getDataSource();
		List<Song> songData = null;
		try {
			// fill list with Song data
			songData = ds.getSongData(); 
		}
				
		catch (Exception e) {
			System.out.print("Unable to connect to Bridges.");
		}
		
		
		String artistName; 
		
		// if statement to get artist name 
		if(args.length > 0) { 
			// get artistName from command line
    		artistName = args[0];
    	}
    	else {
    		// create scanner for user input
    		Scanner in = new Scanner(System.in); 
        	
    		//prompt user for artist name
        	System.out.print("Enter an artist name: "); 
        	artistName = in.nextLine();
    	}
		
		// call getSongsByArtist to get a formatted list by that artist and display the list
		System.out.print(s.getSongsByArtist(artistName));
		

}
	
	/**
	 * Returns a formatted list of all the songs by that artist that appear on the playlist
	 * @param artist
	 * @return String 	A formatted list of the artist's song info
	 */
	public String getSongsByArtist(String artist) {
		
		//create the Bridges object
		Bridges bridges = new Bridges(5, "alcobafloresm", "1181206373013");
		DataSource ds = bridges.getDataSource();
		// fill list with Song data
		List<Song> songData = null;
		try {
			
			songData = ds.getSongData();
		}
				
		catch (Exception e) {
			System.out.println("Unable to connect to Bridges.");
		}
				
		
		//sorts by song album and then song alphabetically 
		Collections.sort(songData, new SongComparator());
		
		
		//string to store lines that contain information about that artist's song
		String full = "";
		// boolean to keep track that the artist passed by the user exists in the playlist
		boolean exists = false;
		
		//create for loop to get info about each song by the artist and store in a string
		for(int i = 0; i < songData.size(); i++) {
		
			Song entry = songData.get(i); 
			
			//check if the artist given by the user is the same as the current artist in the playlist
			if(entry.getArtist().equals(artist)) {
				exists = true; 
				full += "Title: " + entry.getSongTitle() + ": " + entry.getArtist() + " album: " + entry.getAlbumTitle() + "\n";
			}
			
			
		}
		
		// return the formatter list if the artist exists
		if(exists == true) {
			return full;
		}
		//return message if the artist was not found on the playlist
		else {
			return "No songs were found by the given artist on the playlist.";
		}
		
		
		
	}
	
	

}
