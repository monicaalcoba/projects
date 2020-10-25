package cmsc256;
import bridges.data_src_dependent.ActorMovieIMDB;
import bridges.data_src_dependent.Song;
import java.util.Comparator;

/**
 *  SongComparator program
 *  Alcoba-Flores, Monica
 *  Project 3
 *  CMSC 256 Fall 2019, Section 002
 *  September 29, 2019
 *  
 *  This program reads sorts data passed in from the SongList. Sorting is done
 *  by grouping by album and then sorting in alphabetical order by song title
 */

public class SongComparator implements Comparator<Song> {
	
	
	public int compare(Song o1, Song o2) {
		
		// if the album is null sort alphabetically by song title 
		if(o1.getAlbumTitle() == null) {
			
			String p1 = o1.getSongTitle();
			String p2 = o2.getSongTitle();
			
			return -1;
			
			
		}
		if(o2.getAlbumTitle() == null) {
			return 1;
		}
		
		// if album is not null, sort by album and then alphabetically by song title
		if(o1.getAlbumTitle().compareTo(o2.getAlbumTitle()) == 0) {
			
			
				String s1 = o1.getSongTitle();
				String s2 = o2.getSongTitle();
			
				return s1.compareTo(s2);
		}
		
			else {
				return o1.getAlbumTitle().compareTo(o2.getAlbumTitle());
			}
			
		
		
	}

}
