export interface ISunPosition {
  timeOfDayHour: number;
  solarAltitudeDeg: number;
  solarAzimuthDeg: number;
  solarIrradianceWm2: number;
  ambientIntensity: number;
  sunDirectionVector: { x: number; y: number; z: number };
  groundShadowOffset: { x: number; z: number };
}

export class SunPositionEngine {
  /**
   * Calculates sun position vector and ground shadow coordinates for any given time and farm coordinate.
   */
  public static calculateSun(
    timeOfDayHour: number = 10.5,
    latitude: number = 25.4358, // Prayagraj, UP
    longitude: number = 81.8463,
    date: Date = new Date()
  ): ISunPosition {
    const hour = Math.min(18.0, Math.max(6.0, timeOfDayHour));
    const t = (hour - 6.0) / 12.0; // 0.0 at 6 AM, 1.0 at 6 PM

    // Maximum solar elevation around noon (accounting for latitude)
    // India latitudes 10° - 30° experience high elevation ~ 65° - 80° in summer/equinox
    const latRad = (latitude * Math.PI) / 180.0;
    const maxElevDeg = Math.min(82.0, Math.max(55.0, 90.0 - Math.abs(latitude - 23.5) * 0.7));
    const maxElevRad = (maxElevDeg * Math.PI) / 180.0;

    // Sinusoidal elevation
    const altRad = Math.sin(t * Math.PI) * maxElevRad;
    const altDeg = Number(((altRad * 180.0) / Math.PI).toFixed(1));

    // Azimuth: East (-80°) to South (0°) to West (+80°)
    const azRad = (t - 0.5) * Math.PI * 0.88;
    const azDeg = Number(((azRad * 180.0) / Math.PI).toFixed(1));

    // Vector pointing towards the sun
    const safeAlt = Math.max(0.08, altRad);
    const lx = Math.sin(azRad) * Math.cos(safeAlt);
    const ly = Math.sin(safeAlt);
    const lz = -Math.cos(azRad) * Math.cos(safeAlt);

    // Normalize
    const len = Math.sqrt(lx * lx + ly * ly + lz * lz);
    const dirX = lx / len;
    const dirY = ly / len;
    const dirZ = lz / len;

    // Ground shadow projection factor
    const safeLy = Math.max(0.3, dirY);
    const shadowOffsetX = Number(Math.min(1.2, Math.max(-1.2, -dirX / safeLy)).toFixed(3));
    const shadowOffsetZ = Number(Math.min(1.2, Math.max(-1.2, -dirZ / safeLy)).toFixed(3));

    // Irradiance W/m2
    const irradiance = Math.round(Math.max(120.0, Math.sin(t * Math.PI) * 950.0));
    const ambient = Number((0.35 + 0.3 * Math.sin(t * Math.PI)).toFixed(2));

    return {
      timeOfDayHour: hour,
      solarAltitudeDeg: altDeg,
      solarAzimuthDeg: azDeg,
      solarIrradianceWm2: irradiance,
      ambientIntensity: ambient,
      sunDirectionVector: { x: dirX, y: dirY, z: dirZ },
      groundShadowOffset: { x: shadowOffsetX, z: shadowOffsetZ },
    };
  }
}
