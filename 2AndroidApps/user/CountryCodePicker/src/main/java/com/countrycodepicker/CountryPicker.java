package com.countrycodepicker;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Base64;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Currency;
import java.util.List;
import java.util.Locale;

public class CountryPicker extends DialogFragment implements
		Comparator<Country> {
	
	private EditText searchEditText;
	private ListView countryListView;

	private CountryListAdapter adapter;

	private List<Country> allCountriesList;

	private List<Country> selectedCountriesList;

	private CountryPickerListener listener;

	public void setListener(CountryPickerListener listener) {
		this.listener = listener;
	}

	public EditText getSearchEditText() {
		return searchEditText;
	}

	public ListView getCountryListView() {
		return countryListView;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setStyle(DialogFragment.STYLE_NORMAL, R.style.MyDialog);
	}

	public static Currency getCurrencyCode(String countryCode) {
		try {
			return Currency.getInstance(new Locale("en", countryCode));
		} catch (Exception e) {

		}
		return null;
	}

	private List<Country> getAllCountries() {
		if (allCountriesList == null) {
			try {
				allCountriesList = new ArrayList<Country>();
				
				String allCountriesCode = readEncodedJsonString(getActivity());
				
				JSONArray countrArray = new JSONArray(allCountriesCode);
				
				for (int i = 0; i < countrArray.length(); i++) {
					JSONObject jsonObject = countrArray.getJSONObject(i);
					String countryName = jsonObject.getString("name");
					String countryDialCode = jsonObject.getString("dial_code");
					String countryCode = jsonObject.getString("code");
					
					Country country = new Country();
					country.setCode(countryCode);
					country.setName(countryName);
					country.setDialCode(countryDialCode);
					allCountriesList.add(country);
				}

				Collections.sort(allCountriesList, this);

				selectedCountriesList = new ArrayList<Country>();
				selectedCountriesList.addAll(allCountriesList);

				// Return
				return allCountriesList;

			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		return null;
	}

	private static String readEncodedJsonString(Context context)
			throws java.io.IOException {
		String base64 = context.getResources().getString(R.string.countries_code);
		byte[] data = Base64.decode(base64, Base64.DEFAULT);
		return new String(data, "UTF-8");
	}

	/**
	 * To support show as dialog
	 * 
	 * @param dialogTitle
	 * @return
	 */
	public static CountryPicker newInstance(String dialogTitle) {
		CountryPicker picker = new CountryPicker();
		Bundle bundle = new Bundle();
		bundle.putString("dialogTitle", dialogTitle);
		picker.setArguments(bundle);
		return picker;
	}
 
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) { 
		View view = inflater.inflate(R.layout.country_picker, null);
		getAllCountries();
 
		Bundle args = getArguments();
		if (args != null) {
			String dialogTitle = args.getString("dialogTitle");
			getDialog().setTitle(dialogTitle);

			int width = getResources().getDimensionPixelSize(
					R.dimen.cp_dialog_width);
			int height = getResources().getDimensionPixelSize(
					R.dimen.cp_dialog_height);
			getDialog().getWindow().setLayout(width, height);
		}
 
		searchEditText = (EditText) view
				.findViewById(R.id.country_code_picker_search);
		countryListView = (ListView) view
				.findViewById(R.id.country_code_picker_listview);
 
		adapter = new CountryListAdapter(getActivity(), selectedCountriesList);
		countryListView.setAdapter(adapter);
 
		countryListView.setOnItemClickListener(new OnItemClickListener() {

			@Override
			public void onItemClick(AdapterView<?> parent, View view,
									int position, long id) {
				if (listener != null) {
					Country country = selectedCountriesList.get(position);
					listener.onSelectCountry(country.getName(),
							country.getCode(), country.getDialCode());

					// close keyboard
					InputMethodManager mgr = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
					mgr.hideSoftInputFromWindow(searchEditText.getWindowToken(), 0);

				}
			}
		});

		searchEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
			public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
				if (event != null && (event.getKeyCode() == KeyEvent.KEYCODE_ENTER)) {
					// close keyboard
					InputMethodManager mgr = (InputMethodManager) getActivity().getSystemService(Context.INPUT_METHOD_SERVICE);
					mgr.hideSoftInputFromWindow(searchEditText.getWindowToken(), 0);
				}
				return false;
			}
		});


		searchEditText.addTextChangedListener(new TextWatcher() {

			@Override
			public void onTextChanged(CharSequence s, int start, int before,
					int count) {
			}

			@Override
			public void beforeTextChanged(CharSequence s, int start, int count,
					int after) {
			}

			@Override
			public void afterTextChanged(Editable s) {
				search(s.toString());
			}
		});

		return view;
	} 
	
	@SuppressLint("DefaultLocale")
	private void search(String text) {
		selectedCountriesList.clear();

		for (Country country : allCountriesList) {
			if (country.getName().toLowerCase(Locale.ENGLISH)
					.contains(text.toLowerCase())) {
				selectedCountriesList.add(country);
			}
		}

		adapter.notifyDataSetChanged();
	}
 
	@Override
	public int compare(Country lhs, Country rhs) {
		return lhs.getName().compareTo(rhs.getName());
	}

}
