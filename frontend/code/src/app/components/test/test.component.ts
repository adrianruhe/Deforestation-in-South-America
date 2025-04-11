import { Component, OnInit } from '@angular/core';
import { DataService } from '../../services/data.service';
import { FeatureCollection, Feature } from 'geojson';
import * as L from 'leaflet';

@Component({
  selector: 'app-test',
  templateUrl: './test.component.html',
  styleUrls: ['./test.component.scss']
})
export class TestComponent implements OnInit {

  private map!: L.Map;
  private CoverLayer: L.GeoJSON | undefined;
  private selectedLayer: L.GeoJSON | null = null;
  countryStatistics: any;
  private gainLayer: L.GeoJSON | undefined;
  private lossLayer: L.GeoJSON | undefined;
  private borderLayer: L.GeoJSON | null = null; // Store the border layer reference

  isLoading: boolean = true;
  treeCoverChecked: boolean = true;
  forestLossChecked: boolean = false;
  cumulativeLossChecked: boolean = false;
  forestGainChecked: boolean = false;
  selectedYear: number = 2010;
  selectedCountryName: string | null = null;

  constructor(private dataService: DataService) { }


  ngOnInit(): void {
    this.map = L.map('map', {
        preferCanvas: true,
        zoomControl: false // Disable default zoom control
    }).setView([-13, -64.704420], 5);

    var CartoDB_Voyager = L.tileLayer('https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>',
        subdomains: 'abcd',
        maxZoom: 20
    });

    CartoDB_Voyager.addTo(this.map); 
  

    // Add custom zoom control
    const zoomControl = L.control.zoom({ position: 'bottomright' });
    this.map.addControl(zoomControl);

    this.dataService.sampleData().subscribe((result: FeatureCollection) => {
      console.log("Fetched Data from backend (test/testdb):", result)
      
      L.geoJson(result).addTo(this.map);

      this.isLoading = false;
    });

    if (this.treeCoverChecked) {
      this.fetchCoverData();
    }

    this.dataService.borderData().subscribe((result: FeatureCollection) => {
      console.log("Fetched Data from backend (test/borders):", result)
      
      this.borderLayer = L.geoJson(result, {
        style: {
          color: 'black', 
          weight: 1      
        },
        onEachFeature: (feature, layer) => {
          // Add event listeners to each feature
          layer.on({
            mouseover: (event) => {
              // Highlight border on mouseover
              event.target.setStyle({
                color: 'red',  // Highlighted border color
                weight: 2      // Highlighted border weight
              });
            },
            mouseout: (event) => {
              // Reset border style on mouseout
              if (this.selectedLayer !== event.target) {
                this.borderLayer?.resetStyle(event.target);
              }
            },
            click: (event) => {
              // Highlight selected border on click
              if (this.selectedLayer) {
                this.borderLayer?.resetStyle(this.selectedLayer);
              }
              this.selectedLayer = event.target;
              if (this.selectedLayer) {
                this.selectedLayer.setStyle({
                  color: 'blue',  // Selected border color
                  weight: 2       // Selected border weight
                });
                const countryName = event.target.feature.properties.Name; // Assuming 'Name' is the property containing country name
                this.selectedCountryName = countryName; // Update selected country name  
                this.loadCountryStatistics(this.selectedCountryName, this.selectedYear);
              }
            }
          });
        }
      }); 
      if (this.borderLayer) {
        this.borderLayer.addTo(this.map); // Add the borderLayer to the map
      }
    });
  }

  loadCountryStatistics(countryName: string | null, year: number | null): void {
    if (countryName !== null) {
        this.dataService.getCountryStatistics(countryName, year).subscribe(
            (statistics) => {
                console.log('Country Statistics:', statistics);
                this.countryStatistics = statistics; //what is the countryStatistics function called here?
            },
            (error) => {
                console.error('Error fetching country statistics:', error);
                // Handle error
            }
        );
    }
  }

  public fetchCoverData(): void {
    if (this.treeCoverChecked) {
      this.isLoading = true;
      this.dataService.coverData().subscribe((result: FeatureCollection) => {
        console.log("Overall Forest Cover Data:", result);
  
        if (this.CoverLayer) {
          this.map.removeLayer(this.CoverLayer);
        }
  
        this.CoverLayer = L.geoJson(result, {
          style: {
            fillColor: 'green',
            fillOpacity: 0.5,
            color: 'green',
            opacity: 0,
            weight: 1
          }
        }).addTo(this.map);
  
        this.isLoading = false;
      });
    } else {
      // If the checkbox is unchecked, remove the forest cover layer from the map
      if (this.CoverLayer) {
        this.map.removeLayer(this.CoverLayer);
        this.CoverLayer = undefined;
      }
    }
  }
  

  updateStatisticsForYear(): void {
    // Call the data service method to fetch statistics for the selected year
    if (this.selectedCountryName !== null) {
      this.loadCountryStatistics(this.selectedCountryName, this.selectedYear);
    }
  }
  
  private loadGainData(): void {
    this.dataService.gainData().subscribe((result: FeatureCollection) => {
      console.log("Gain Data from backend (test/gain):", result);

      if (this.gainLayer) {
        this.map.removeLayer(this.gainLayer);
      }

      this.gainLayer = L.geoJson(result, {
        style: {
          fillColor: 'green',
          fillOpacity: 0.5,
          color: 'green',
          opacity: 1,
          weight: 1
        }
      }).addTo(this.map);

      this.isLoading = false;
    });
  }

  public fetchGainData(): void {
    if (this.forestGainChecked) {
      this.isLoading = true;
      this.loadGainData();
    } else {
      if (this.gainLayer) {
        this.map.removeLayer(this.gainLayer);
        this.gainLayer = undefined;
      }
    }
  }

  public fetchLossData(): void {
    if (this.forestLossChecked) {
      this.isLoading = true;
      this.loadLossData();
    } else {
      // If the checkbox is unchecked, remove the loss data layer from the map
      if (this.lossLayer) {
        this.map.removeLayer(this.lossLayer);
        this.lossLayer = undefined;
      }
    }
  }
  
  private loadLossData(): void {
    if (this.forestLossChecked) {
      if (this.cumulativeLossChecked) {
        // If cumulative loss is checked, call the cumulative loss data route
        this.dataService.cumulativelossData(this.selectedYear).subscribe((result: FeatureCollection) => {
          console.log("Cumulative Loss Data:", result);
          if (this.lossLayer) {
            this.map.removeLayer(this.lossLayer);
          }
          // Create new loss layer and add it to the map
          this.lossLayer = L.geoJson(result, {
            style: {
              fillColor: 'red',
              fillOpacity: 0.5,
              color: 'red',
              opacity: 1,
              weight: 1
            }
          }).addTo(this.map);
          this.isLoading = false;
        });
      } else {
        // If cumulative loss is not checked, call the regular loss data route
        this.dataService.lossData(this.selectedYear).subscribe((result: FeatureCollection) => {
          console.log("Loss Data from backend (test/loss):", result);
          // Process and display loss data for the selected year
          // Remove existing loss layer if present
          if (this.lossLayer) {
            this.map.removeLayer(this.lossLayer);
          }
          // Create new loss layer and add it to the map
          this.lossLayer = L.geoJson(result, {
            style: {
              fillColor: 'red',
              fillOpacity: 0.5,
              color: 'red',
              opacity: 1,
              weight: 1
            }
          }).addTo(this.map);
          this.isLoading = false;
        });
      }
    } else {
      // If the checkbox is unchecked, remove the loss data layer from the map
      if (this.lossLayer) {
        this.map.removeLayer(this.lossLayer);
        this.lossLayer = undefined;
      }
    }
  }
  
  updateForestLoss() {
    if (this.cumulativeLossChecked) {
      this.forestLossChecked = true; 
    }
    if (!this.forestLossChecked) {
      this.cumulativeLossChecked = false;
    }
  }
}