package test.com.test.view;

import android.arch.lifecycle.Observer;
import android.arch.lifecycle.ViewModelProvider;
import android.arch.lifecycle.ViewModelProviders;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.view.Gravity;
import android.view.View;
import android.widget.EditText;
import android.widget.Toast;

import java.util.ArrayList;
import java.util.List;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;
import retrofit2.Retrofit;
import retrofit2.converter.gson.GsonConverterFactory;

import test.com.test.R;
import test.com.test.model.Hero;
import test.com.test.viewmodel.HeroesViewModel;
//import test.com.test.viewmodel.HeroesViewModel;

public class MainActivity extends AppCompatActivity {

    RecyclerView recyclerView;
    HeroesAdapter adapter;
    EditText edtOperation;

    List<Hero> heroList;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        recyclerView = findViewById(R.id.recyclerview);
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));
        edtOperation = findViewById(R.id.edtOperation);
    }

    public void clickOperation(View v){

        try {
            String operation = edtOperation.getText().toString();

            if(operation.length() != 0) {

                ScriptEngineManager manager = new ScriptEngineManager();
                ScriptEngine engine = manager.getEngineByName("js");
              //  engine.put("X", 3);

                Object operations = engine.eval(operation);
              //  Toast.makeText(getApplicationContext(), , Toast.LENGTH_LONG).show();
                Toast toast = Toast.makeText(getApplicationContext(),getResources().getString(R.string.app_operation_result) + ": " + operations, Toast.LENGTH_LONG);
                toast.setGravity(Gravity.CENTER, 100, 100);
                toast.show();
                double res = asDouble(operations);
                showResult(res);
            }else{
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_empty), Toast.LENGTH_LONG).show();
            }
        }catch (Exception e){
            e.printStackTrace();
            Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_fail), Toast.LENGTH_LONG).show();
        }
    }

    public Double asDouble(Object o) {
        Double val = null;
        if (o instanceof Number) {
            val = ((Number) o).doubleValue();
        }
        return val;
    }

    public void showResult(Double result){

        int res;
        if(result % 3 == 0){
            res = 3;
        }else if(result % 5 == 0){
            res = 5;
        }else if(result % 7 == 0){
            res = 7;
        }else if(result % 9 == 0){
            res = 9;
        }else if(result % 11 == 0){
            res = 11;
        }else{
            res = 0;
        }

        switch (res){
            case 0:
           //     Toast.makeText(getApplicationContext(), "0", Toast.LENGTH_LONG).show();
                break;
            case 1:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 1, Toast.LENGTH_LONG).show();
                break;
            case 3:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 3, Toast.LENGTH_LONG).show();
                break;
            case 5:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 5, Toast.LENGTH_LONG).show();
                break;
            case 7:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 7, Toast.LENGTH_LONG).show();
                break;
            case 9:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 9, Toast.LENGTH_LONG).show();
                break;
            case 11:
                Toast.makeText(getApplicationContext(), getResources().getString(R.string.app_operation_result) + ": " + result + " " + getResources().getString(R.string.app_operation_multiple) + 11, Toast.LENGTH_LONG).show();
                break;
            default:

        }
        HeroesViewModel model = ViewModelProviders.of(this).get(HeroesViewModel.class);

        model.getHeroes().observe(this, new Observer<List<Hero>>() {
            @Override
            public void onChanged(@Nullable List<Hero> heroList) {
                adapter = new HeroesAdapter(MainActivity.this, heroList);
                recyclerView.setAdapter(adapter);
            }
        });
    }
}