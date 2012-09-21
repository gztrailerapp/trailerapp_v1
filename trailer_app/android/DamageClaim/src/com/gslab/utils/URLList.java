package com.gslab.utils;

import android.util.Log;

import com.gslab.interfaces.Constants;

public class URLList {

	private final static String PARENT				 =				 "http://gizurtrailerapp-env.elasticbeanstalk.com/api/index.php/api";
	private final static String LOGIN   			 =  			 "/Authenticate/login";
	private final static String ASSETS				 = 				 "/Assets";
	private final static String SEALED_PICKLIST		 =				 "/HelpDesk/sealed";
	private final static String DAMAGE_TYPE 		 = 				 "/HelpDesk/damagetype";
	private final static String HELPDESKURL			 =				 "/HelpDesk";
	private final static String PREVIOUS_DAMAGES	 = 				 "/HelpDesk/damaged";
		
	public static String getURL(final int which)
	{
		
		String url = PARENT;
		
		switch(which)
		{
					
		case Constants.LOGIN : return (url + LOGIN);
		
		case Constants.PARENT : return url;
		
		case Constants.ASSETS_DATA : return (url + ASSETS);
		
		case Constants.SEALED : return(url + SEALED_PICKLIST);
		
		case Constants.HELPDESK_URL : return(url + HELPDESKURL);
		
		case Constants.PREVIOUS_DAMAGES : return(url + PREVIOUS_DAMAGES);
		
		case Constants.DAMAGE_TYPE : return(url + DAMAGE_TYPE);
		
		default : Log.i("URLList.java", "in default case");
		return null;
		
		}
		
		
	}
	
	
	
}