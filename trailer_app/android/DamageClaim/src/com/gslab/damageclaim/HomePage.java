package com.gslab.damageclaim;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import com.gslab.R;
import com.gslab.R.layout;
import com.gslab.R.string;
import com.gslab.core.CoreComponent;
import com.gslab.core.DamageClaimApp;
import com.gslab.interfaces.Constants;
import com.gslab.interfaces.NetworkListener;
import com.gslab.networking.HTTPRequest;
import com.gslab.uihelpers.ListViewDialog;
import com.gslab.uihelpers.ProgressDialogHelper;
import com.gslab.uihelpers.ToastUI;
import com.gslab.utils.NetworkCallRequirements;
import com.gslab.utils.URLList;
import com.gslab.utils.Utility;

public class HomePage extends Activity implements OnClickListener,
		NetworkListener, Runnable {

	private TextView trailertype, id, place, sealed, plates, straps;
	private ArrayList<String> values, sealed_labels, ids;

	private RelativeLayout trailerinventory;

	private Button submit, damages;

	private int selection;

	private String response;

	private JSONObject object;
	private JSONArray array;

	private Thread thread;

	private ScrollView scrollview;

	public void onCreate(Bundle savedInstanceState) {

		super.onCreate(savedInstanceState);
		setContentView(R.layout.homepage);

		scrollview = (ScrollView) findViewById(com.gslab.R.id.scrollview_homepage);

		getApplicationContext();

		values = new ArrayList<String>();
		sealed_labels = new ArrayList<String>();

		trailerinventory = (RelativeLayout) findViewById(R.id.trailer_inventory);

		trailertype = (TextView) findViewById(R.id.homepage_textview_trailertype);
		trailertype.setText(getString(string.homepage_textview_trailertype)
				+ " " + getString(string.trailer_type_own));
		trailertype.setOnClickListener(this);
		DamageClaimApp.trailer_type = Utility.getParsedString(trailertype
				.getText().toString());

		id = (TextView) findViewById(R.id.homepage_textview_id);
		id.setOnClickListener(this);

		place = (TextView) findViewById(R.id.homepage_textview_place);
		place.setOnClickListener(this);

		sealed = (TextView) findViewById(R.id.homepage_textview_sealed);
		sealed.setOnClickListener(this);

		plates = (TextView) findViewById(R.id.homepage_textview_plates);
		plates.setOnClickListener(this);

		straps = (TextView) findViewById(R.id.homepage_textview_straps);
		straps.setOnClickListener(this);

		submit = (Button) findViewById(R.id.homepage_button_submit);
		submit.setEnabled(false);
		submit.setOnClickListener(this);

		damages = (Button) findViewById(R.id.homepage_button_damages);
		damages.setOnClickListener(this);
		selection = Constants.SEALED;
		thread = new Thread(this);
		thread.start();

		addTrailerInventory();

	}

	private Handler handler = new Handler() {

		public void handleMessage(Message msg) {

			switch (msg.what) {
			case Constants.DISMISS_DIALOG:
				ProgressDialogHelper.dismissProgressDialog();
				break;
			case 1:
				setSealedValue();
				break;

			case Constants.TOAST:
				errordialog();
				break;

			}

		}
	};

	private void errordialog() {
		Utility.showErrorDialog(this);
	}

	private void setSealedValue() {
		sealed.setText(getString(string.homepage_textview_sealed) + " "
				+ values.get(sealed_labels.indexOf("no")));
		DamageClaimApp.sealed = Utility.getParsedString(sealed.getText()
				.toString());
	}

	@SuppressWarnings("unchecked")
	private void getPlateValues() {

		if (DamageClaimApp.plates_values != null) {
			values = (ArrayList<String>) DamageClaimApp.plates_values.clone();
			return;
		}

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}

		values = new ArrayList<String>();

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();

		if (this.response == null) {
			values = null;
			return;
		}

		try {
			object = new JSONObject(this.response);
			array = object.getJSONArray("result");
			for (int i = 0; i < array.length(); i++) {
				values.add(array.getJSONObject(i).getString("value"));
			}
		} catch (Exception e) {

			e.printStackTrace();
		}
		DamageClaimApp.plates_values = (ArrayList<String>) values.clone();

	}

	@SuppressWarnings("unchecked")
	private void getStrapsValues() {
		values = new ArrayList<String>();

		if (DamageClaimApp.straps_values != null) {
			values = (ArrayList<String>) DamageClaimApp.straps_values.clone();
			return;
		}

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();

		if (this.response == null) {
			values = null;
			return;
		}

		try {
			object = new JSONObject(this.response);
			array = object.getJSONArray("result");

			for (int i = 0; i < array.length(); i++) {
				values.add(array.getJSONObject(i).getString("value"));
			}
		} catch (Exception e) {

			e.printStackTrace();
		}
		DamageClaimApp.straps_values = (ArrayList<String>) values.clone();
	}

	private void getTrailerTypeValues() {
		values = new ArrayList<String>();
		values.add(getString(string.trailer_type_own));
		values.add(getString(string.trailer_type_rented));
	}

	@SuppressWarnings("unchecked")
	private void getIDValues() // To be fetched from URL
	{
		values = new ArrayList<String>();
		values.clear();
		if (DamageClaimApp.id_names != null && DamageClaimApp.id_values != null) {
			values = (ArrayList<String>) DamageClaimApp.id_names.clone();
			ids = (ArrayList<String>) DamageClaimApp.id_values.clone();
			return;
		}

		ids = new ArrayList<String>();

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.processRequest(Constants.GET, Constants.ASSETS, this,
				createRequest());
		Utility.waitForThread();

		if (this.response == null) {
			values = null;
			return;
		}

		if (this.response != null) {
			try {
				object = new JSONObject(response);
				array = object.getJSONArray("result");
				for (int i = 0; i < array.length(); i++) {
					if (array.getJSONObject(i).getString("assetstatus")
							.equalsIgnoreCase("In Service")) {
						values.add(array.getJSONObject(i)
								.getString("assetname"));
						ids.add(array.getJSONObject(i).getString("id"));
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			DamageClaimApp.id_names = (ArrayList<String>) values.clone();
			DamageClaimApp.id_values = (ArrayList<String>) ids.clone();

		}

	}

	@SuppressWarnings("unchecked")
	private void getPlaceValues() // To be fetched from URL
	{

		values = new ArrayList<String>();

		if (DamageClaimApp.places_values != null) {
			values = (ArrayList<String>) DamageClaimApp.places_values.clone();
			return;
		}

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}

		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();

		if (this.response == null) {
			values = null;
			return;
		}

		try {
			object = new JSONObject(this.response);
			array = object.getJSONArray("result");

			for (int i = 0; i < array.length(); i++) {
				values.add(array.getJSONObject(i).getString("value"));
			}
		} catch (Exception e) {
			Log.i(getClass().getSimpleName(),
					"---------------------------------------");
			e.printStackTrace();
		}

		DamageClaimApp.places_values = (ArrayList<String>) values.clone();

	}

	@SuppressWarnings("unchecked")
	private void getSealedValues() { // Requirement - 1 . sealed_lables, 2.
										// sealed_values
		values = new ArrayList<String>();
		sealed_labels.clear();

		if (DamageClaimApp.sealed_labels != null
				&& DamageClaimApp.sealed_values != null) {
			values = (ArrayList<String>) DamageClaimApp.sealed_values.clone();
			sealed_labels = (ArrayList<String>) DamageClaimApp.sealed_labels
					.clone();
			return;
		}

		if (!NetworkCallRequirements.isNetworkAvailable(this)) {
			Log.i("got it", "the network info");
			ToastUI.showToast(getApplicationContext(),
					getString(string.networkunavailable));
			return;
		}
		ProgressDialogHelper.showProgressDialog(this, "",
				getString(string.loading));

		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				createRequest());
		Utility.waitForThread();

		if (this.response == null) {
			values = null;
			return;
		}
		if (this.response != null) {
			try {
				object = new JSONObject(response);
				array = object.getJSONArray("result");
				for (int i = 0; i < array.length(); i++) {
					if (array.getJSONObject(i).getString("label")
							.equalsIgnoreCase("yes"))
						values.add(getString(string.sealed_yes));
					if (array.getJSONObject(i).getString("label")
							.equalsIgnoreCase("no"))
						values.add(getString(string.sealed_no));
					sealed_labels
							.add(array.getJSONObject(i).getString("label"));
					Log.i("sealed label", sealed_labels.get(i));
					Log.i(getClass().getSimpleName(), values.get(i));

				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			DamageClaimApp.sealed_labels = (ArrayList<String>) sealed_labels
					.clone();
			DamageClaimApp.sealed_values = (ArrayList<String>) values.clone();
		}

	}

	public void setListSelectedItemId(long id) {
		switch (selection) {
		case Constants.TRAILER_TYPE:
			trailertype.setText(getString(string.homepage_textview_trailertype)
					+ " " + values.get((int) id));
			DamageClaimApp.trailer_type = Utility.getParsedString(trailertype
					.getText().toString());
			break;

		case Constants.ID:
			this.id.setText(getString(string.homepage_textview_ID) + " "
					+ values.get((int) id));
			if (values.get((int) id).equalsIgnoreCase(""))
				CoreComponent.trailerid = null;
			else {
				CoreComponent.trailerid = values.get((int) id);
				Log.i(getClass().getSimpleName(), CoreComponent.trailerid + "");
			}
			checkSubmitButtonStatus();
			break;

		case Constants.PLACE:
			place.setText(getString(string.homepage_textview_place) + " "
					+ values.get((int) id));
			DamageClaimApp.place = Utility.getParsedString(place.getText()
					.toString());
			break;

		case Constants.SEALED:
			sealed.setText(getString(string.homepage_textview_sealed) + " "
					+ values.get((int) id));
			if (((int) id) == Constants.YES)
				removeTrailerInventory();
			else
				addTrailerInventory();
			DamageClaimApp.sealed = Utility.getParsedString(sealed.getText()
					.toString());
			break;

		case Constants.PLATES:
			plates.setText(getString(string.homepage_textview_plates) + " "
					+ values.get((int) id));
			DamageClaimApp.plates = Utility.getParsedString(plates.getText()
					.toString());
			break;

		case Constants.STRAPS:
			straps.setText(getString(string.homepage_textview_straps) + " "
					+ values.get((int) id));
			DamageClaimApp.straps = Utility.getParsedString(straps.getText()
					.toString());
			break;
		}
	}

	private void checkSubmitButtonStatus() {

		if (id.getText().toString()
				.equalsIgnoreCase(getString(string.homepage_textview_ID))) {
			submit.setEnabled(false);
		} else {
			submit.setEnabled(true);
		}

	}

	private void removeTrailerInventory() {
		trailerinventory.setVisibility(RelativeLayout.GONE);
	}

	private void addTrailerInventory() {
		trailerinventory.setVisibility(RelativeLayout.VISIBLE);
	}

	private void setDefaultValues() {
		scrollview.scrollTo(0, scrollview.getTop());
		trailertype.setText(getString(string.homepage_textview_trailertype)
				+ " " + getString(string.trailer_type_own));
		id.setText(getString(string.homepage_textview_ID));
		place.setText(getString(string.homepage_textview_place));
		sealed.setText(getString(string.homepage_textview_sealed) + " "
				+ getString(string.sealed_no));
		plates.setText(getString(string.homepage_textview_plates));
		straps.setText(getString(string.homepage_textview_straps));
		trailerinventory.setVisibility(RelativeLayout.VISIBLE);
		submit.setEnabled(false);
		CoreComponent.trailerid = null;
		DamageClaimApp.trailer_type = Utility.getParsedString(trailertype
				.getText().toString());
		DamageClaimApp.place = null;
		DamageClaimApp.straps = null;
		DamageClaimApp.plates = null;
		DamageClaimApp.sealed = Utility.getParsedString(sealed.getText()
				.toString());
	}

	public void onClick(View v) {

		if (v == trailertype) {
			selection = Constants.TRAILER_TYPE;
			getTrailerTypeValues();

			new ListViewDialog(this, layout.listviewdialog,
					getString(string.homepage_textview_trailertype), values,
					Constants.HOMEPAGE);
		}

		if (v == id) {
			selection = Constants.ID;
			getIDValues();
			if (this.response != null || values != null)
				new ListViewDialog(this, layout.listviewdialog,
						getString(string.homepage_textview_ID), values,
						Constants.HOMEPAGE);
		}

		if (v == place) {
			selection = Constants.PLACE;
			getPlaceValues();
			if (this.response != null || values != null)
				new ListViewDialog(this, layout.listviewdialog,
						getString(string.homepage_textview_place), values,
						Constants.HOMEPAGE);
		}

		if (v == sealed) {
			selection = Constants.SEALED;
			getSealedValues();

			if (this.response != null || values != null)
				new ListViewDialog(this, layout.listviewdialog,
						getString(string.homepage_textview_sealed), values,
						Constants.HOMEPAGE);
		}

		if (v == plates) {
			selection = Constants.PLATES;
			getPlateValues();
			if (this.response != null || values != null)
				new ListViewDialog(this, layout.listviewdialog,
						getString(string.homepage_textview_plates), values,
						Constants.HOMEPAGE);
		}

		if (v == straps) {
			selection = Constants.STRAPS;
			getStrapsValues();
			if (this.response != null || values != null)
				new ListViewDialog(this, layout.listviewdialog,
						getString(string.homepage_textview_straps), values,
						Constants.HOMEPAGE);
		}

		if (v == damages) {

			if (performChecks()) {

				Intent intent = new Intent(getApplicationContext(),
						ReportDamage.class);
				startActivity(intent);
			}
			else 						/*------------------------translation required-------------------*/
				ToastUI.showToast(getApplicationContext(), "Please fill all the fields");

		}

		if (v == submit) {

			if (id.getText().toString()
					.equalsIgnoreCase(getString(string.homepage_textview_ID))) {
				ToastUI.showToast(getApplicationContext(),
						getString(string.selectid));
				return;
			}

			selection = Constants.SUBMIT;

			if (!NetworkCallRequirements.isNetworkAvailable(this)) {
				Log.i("got it", "the network info");
				ToastUI.showToast(getApplicationContext(),
						getString(string.networkunavailable));
				return;
			}

			ProgressDialogHelper.showProgressDialog(this, "",
					getString(string.loading));

			HTTPRequest request = CoreComponent
					.getRequest(Constants.HELPDESK_URL);
			request.addParam("ticket_title", getString(string.surveyticketby)
					+ CoreComponent.getUserinfo().getContactname());
			request.addParam("ticketstatus", getClosedTicketStatusValue());
			request.addParam("trailerid", CoreComponent.trailerid);
			request.addParam("reportdamage", getReportDamageValueNo());

			/*
			 * need to check the sealed condition what about trailer type?
			 */

			if (DamageClaimApp.place != null)
				request.addParam("damagereportlocation", DamageClaimApp.place);
			if (DamageClaimApp.sealed != null)
				request.addParam("sealed", DamageClaimApp.sealed);
			if (DamageClaimApp.sealed
					.equalsIgnoreCase(getString(string.sealed_no))) {
				if (DamageClaimApp.straps != null)
					request.addParam("straps", DamageClaimApp.straps);
				if (DamageClaimApp.plates != null)
					request.addParam("plates", DamageClaimApp.plates);
			}

			CoreComponent.processRequest(Constants.POST, Constants.HELPDESK,
					this, request);

			Utility.waitForThread();

			if (this.response != null) {
				ToastUI.showToast(getApplicationContext(),
						getString(string.submit_survey));
				setDefaultValues();
			}

		}

	}

	private boolean performChecks() {
		
		if(DamageClaimApp.place != null
			&& DamageClaimApp.trailer_type != null
			&& CoreComponent.trailerid != null
			&& DamageClaimApp.sealed != null){
			if(DamageClaimApp.sealed.equalsIgnoreCase(getString(string.sealed_no))) {
				if(DamageClaimApp.plates != null && DamageClaimApp.straps != null)
					return true;
				else
					return false;
			}
			else
				return true;
			
		}
		return false;
			
		
	}

	private String getReportDamageValueNo() {

		if (DamageClaimApp.report_damage_value_no != null) {
			return DamageClaimApp.report_damage_value_no;
		}

		int temp = selection;
		selection = Constants.REPORTDAMAGE;
		HTTPRequest request = createRequest();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				request);
		Utility.waitForThread();
		if (this.response != null) {
			try {
				JSONObject obj = new JSONObject(response);
				JSONArray arr = obj.getJSONArray("result");
				for (int i = 0; i < arr.length(); i++) {

					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("yes")) {
						DamageClaimApp.report_damage_value_yes = new String(arr
								.getJSONObject(i).getString("value"));
					}

					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("no")) {
						Log.i(getClass().getSimpleName(), arr.getJSONObject(i)
								.getString("value"));
						DamageClaimApp.report_damage_value_no = new String(arr
								.getJSONObject(i).getString("value"));
						selection = temp;
						return arr.getJSONObject(i).getString("value");
					}
				}
				handler.sendEmptyMessage(Constants.TOAST);
			} catch (Exception e) {
				handler.sendEmptyMessage(Constants.TOAST);
				Log.i(getClass().getSimpleName(),
						"getclosedticketstatusvalue... exception");
			}
		}
		selection = temp;
		return null;
	}

	@Override
	protected void onResume() {
		setDefaultValues();
		super.onResume();
	}

	public boolean onCreateOptionsMenu(Menu menu) {

		menu.add(Menu.NONE, 1, Menu.NONE,
				getString(string.homepage_button_reset));

		menu.add(Menu.NONE, 2, Menu.NONE, getString(string.changepassword));
		menu.add(Menu.NONE, Constants.LOGOUT, Menu.NONE,
				getString(string.logout));
		return super.onCreateOptionsMenu(menu);
	}

	public boolean onOptionsItemSelected(MenuItem item) {

		super.onOptionsItemSelected(item);

		switch (item.getItemId()) {
		case 1:
			setDefaultValues();
			break;

		case Constants.LOGOUT:
			CoreComponent.LOGOUT_CALL = true;
			Log.i("logging out", "here");
			if (!NetworkCallRequirements.isNetworkAvailable(this)) {
				Log.i("got it", "the network info");
				ToastUI.showToast(getApplicationContext(),
						getString(string.networkunavailable));

			} else {
				Log.i(getClass().getSimpleName(), "logging out");
				ProgressDialogHelper.showProgressDialog(this, "",
						getString(string.loading));
				Log.i(getClass().getSimpleName(),
						URLList.getURL(Constants.LOGOUT));
				CoreComponent.logout(this);
			}
			break;
		case 2:
			Intent intent = new Intent(getApplicationContext(),
					PasswordReset.class);
			startActivity(intent);
			break;
		}

		return true;
	}

	public void onSuccessFinish(String response) {

		this.response = response;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);

	}

	public void onError(String status) {
		this.response = null;
		handler.sendEmptyMessage(Constants.DISMISS_DIALOG);
		handler.sendEmptyMessage(Constants.TOAST);

	}

	public void run() {
		getSealedValues();
		if (sealed_labels.contains("no")) {
			handler.sendEmptyMessage(1);

		}

	}

	private String getClosedTicketStatusValue() {

		if (DamageClaimApp.closed_ticket_status_value != null) {
			return DamageClaimApp.closed_ticket_status_value;
		}

		int temp = selection;
		selection = Constants.TICKETSTATUS;
		HTTPRequest request = createRequest();
		CoreComponent.processRequest(Constants.GET, Constants.HELPDESK, this,
				request);
		Utility.waitForThread();
		if (this.response != null) {
			try {
				JSONObject obj = new JSONObject(response);
				JSONArray arr = obj.getJSONArray("result");
				for (int i = 0; i < arr.length(); i++) {

					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("open")) {
						DamageClaimApp.open_ticket_status_value = new String(
								arr.getJSONObject(i).getString("value"));
					}

					if (arr.getJSONObject(i).getString("label")
							.equalsIgnoreCase("closed")) {
						Log.i(getClass().getSimpleName(), arr.getJSONObject(i)
								.getString("value"));
						DamageClaimApp.closed_ticket_status_value = new String(
								arr.getJSONObject(i).getString("value"));
						selection = temp;
						return arr.getJSONObject(i).getString("value");
					}
				}
				handler.sendEmptyMessage(Constants.TOAST);
			} catch (Exception e) {
				handler.sendEmptyMessage(Constants.TOAST);
				Log.i(getClass().getSimpleName(), "damage report... exception");
			}
		}
		selection = temp;
		return null;
	}

	public HTTPRequest createRequest() {

		if (CoreComponent.LOGOUT_CALL) {
			return CoreComponent.getRequest(Constants.LOGOUT);
		}

		HTTPRequest request = null;
		Log.i("selection", selection + "");
		switch (selection) {

		case Constants.ID:
			request = CoreComponent.getRequest(Constants.ASSETS_DATA);
			break;

		case Constants.SEALED:
			request = CoreComponent.getRequest(Constants.SEALED);
			break;

		case Constants.SUBMIT:
			request = CoreComponent.getRequest(Constants.HELPDESK_URL);
			request.addParam("ticket_title", getString(string.surveyticketby)
					+ CoreComponent.getUserinfo().getContactname());
			request.addParam("ticketstatus", getClosedTicketStatusValue());
			request.addParam("trailerid", CoreComponent.trailerid);
			request.addParam("reportdamage", getReportDamageValueNo());

			/*
			 * need to check the sealed condition what about trailer type?
			 */

			if (DamageClaimApp.place != null)
				request.addParam("damagereportlocation", DamageClaimApp.place);
			if (DamageClaimApp.sealed != null)
				request.addParam("sealed", DamageClaimApp.sealed);
			if (DamageClaimApp.sealed
					.equalsIgnoreCase(getString(string.sealed_no))) {
				if (DamageClaimApp.straps != null)
					request.addParam("straps", DamageClaimApp.straps);
				if (DamageClaimApp.plates != null)
					request.addParam("plates", DamageClaimApp.plates);
			}

			break;

		case Constants.TICKETSTATUS:
			request = CoreComponent.getRequest(Constants.TICKETSTATUS);
			break;

		case Constants.REPORTDAMAGE:
			request = CoreComponent.getRequest(Constants.REPORTDAMAGE);
			break;

		case Constants.PLATES:
			request = CoreComponent.getRequest(Constants.PLATES);
			break;

		case Constants.STRAPS:
			request = CoreComponent.getRequest(Constants.STRAPS);
			break;

		case Constants.PLACE:
			request = CoreComponent.getRequest(Constants.PLACE);
			break;
		}
		return request;

	}
}
