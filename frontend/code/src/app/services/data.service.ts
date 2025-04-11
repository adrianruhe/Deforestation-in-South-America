import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { FeatureCollection } from 'geojson';
import { environment } from 'src/environments/environment';


const httpOptions = {
  headers: new HttpHeaders({
    'Content-Type': 'application/json',
  }),
  params: new HttpParams()
}

@Injectable({
  providedIn: 'root'
})
export class DataService {

  constructor(private http: HttpClient) { }

  /*
  calls the default dbtest route from the backend
  --> sampleData() function to call backend route dbtest
  */ 
 
  public sampleData(): Observable<FeatureCollection>  {
    const url = environment.api + '/test/dbtest';

    return this.http.get<FeatureCollection>(url, httpOptions);
  }

  public coverData(): Observable<FeatureCollection> {
    const url = environment.api + '/test/cover'; 
    console.log(url)

    return this.http.get<FeatureCollection>(url);
  }

  public gainData(): Observable<FeatureCollection>  {
    const url = environment.api + '/test/gain';

    return this.http.get<FeatureCollection>(url, httpOptions);
  }

  public lossData(year: number | null): Observable<FeatureCollection> {
    let url = environment.api + '/test/loss';
    if (year !== null) {
      url += `?year=${year}`;
    }
    return this.http.get<FeatureCollection>(url, httpOptions);
  }

  public cumulativelossData(year: number | null): Observable<FeatureCollection> {
    let url = environment.api + '/test/loss_cumulative';
    if (year !== null) {
      url += `?year=${year}`;
    }
    return this.http.get<FeatureCollection>(url, httpOptions);
  }

  public borderData(): Observable<FeatureCollection>  {
    const url = environment.api + '/test/borders';

    return this.http.get<FeatureCollection>(url, httpOptions);
  }

  public getCountryStatistics(countryName: string, year: number | null): Observable<any> {
    let url = `${environment.api}/test/country_statistics/${countryName}`;
    if (year !== null) {
        url += `?year=${year}`;
        console.log(url)
    }

    return this.http.get<any>(url);
  }

  public getCoverDataRaster(): Observable<FeatureCollection> {
    const url = environment.api + '/cover_data_r';
    return this.http.get<FeatureCollection>(url, httpOptions);
  }  
}

