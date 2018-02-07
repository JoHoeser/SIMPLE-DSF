// NTC auslesen un Daten weitergeben... 
float ReadNTC()
{
    float media;
    
    // NTC-Werte SAMPLES Mal auslesen und in Array speichern
    for (i=0; i< SAMPLES; i++) {
    sampleArray[i] = analogRead(THERMISTORPIN);
    delay(10);
    }
    
    media = 0;
    for (i=0; i< SAMPLES; i++) media += sampleArray[i];
    media /= SAMPLES;
    // NTC Widerstand umwandeln
    media = 1023 / media - 1;
    media = SERIESRESISTOR / media;
    
    // Temperatur mittels beta-Faktor Gleichung berechnen

    NTCtemp = media / NOM_THERMISTOR;      // (R/Ro)
    NTCtemp = log(NTCtemp);                // ln(R/Ro)
    NTCtemp /= BCOEFFICIENT;               // 1/B * ln(R/Ro)
    NTCtemp += 1.0 / (NOM_TEMP + 273.15);  // + (1/To)
    NTCtemp = 1.0 / NTCtemp;               // Wert invertieren
    NTCtemp -= 273.15;                     // in Celsius umwandeln
    
    return NTCtemp;

}
