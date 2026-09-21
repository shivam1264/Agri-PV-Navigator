let scene, camera, renderer, controls;
let instancedPanels, instancedStilts, boundaryLine, instancedFrames, instancedBeams, instancedBases, instancedCrops;
let sunLight;

window.initAgriPvScene = function(containerId) {
    const container = document.getElementById(containerId);
    if (!container) {
        console.error("Three.js container not found:", containerId);
        return;
    }

    // 1. Setup Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x87CEEB); // Sky blue
    scene.fog = new THREE.FogExp2(0x87CEEB, 0.015);

    // 2. Setup Camera
    camera = new THREE.PerspectiveCamera(50, container.clientWidth / container.clientHeight, 0.1, 1000);
    camera.position.set(0, 6, 12); // Cinematic Eye-level/Human-scale height

    // 3. Setup Renderer (Upgraded for Realism)
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.setPixelRatio(window.devicePixelRatio); // Sharper rendering
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    renderer.toneMapping = THREE.ACESFilmicToneMapping; // Cinematic lighting
    renderer.toneMappingExposure = 0.85;
    renderer.outputEncoding = THREE.sRGBEncoding;
    container.appendChild(renderer.domElement);

    // 4. Setup Controls
    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.maxPolarAngle = Math.PI / 2 - 0.05; // Don't clip ground
    controls.minDistance = 2;
    controls.maxDistance = 150;
    controls.target.set(0, 2, 0); // Look slightly up

    // 5. Lighting & Atmospheric Sky
    // Sky
    const sky = new THREE.Sky();
    sky.scale.setScalar(450000);
    scene.add(sky);

    const sunSphere = new THREE.Vector3();
    
    // Ambient Light
    const ambientLight = new THREE.HemisphereLight(0xffffff, 0x444455, 0.35);
    scene.add(ambientLight);

    sunLight = new THREE.DirectionalLight(0xffffee, 1.2);
    sunLight.position.set(20, 50, 20);
    sunLight.castShadow = true;
    sunLight.shadow.mapSize.width = 2048;
    sunLight.shadow.mapSize.height = 2048;
    sunLight.shadow.camera.near = 0.5;
    sunLight.shadow.camera.far = 200;
    const d = 60;
    sunLight.shadow.camera.left = -d;
    sunLight.shadow.camera.right = d;
    sunLight.shadow.camera.top = d;
    sunLight.shadow.camera.bottom = -d;
    sunLight.shadow.bias = -0.0005;
    scene.add(sunLight);

    // 6. Ground Plane (Enhanced Realism)
    const textureLoader = new THREE.TextureLoader();
    textureLoader.load('assets/assets/images/farm_satellite.jpg', function(texture) {
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.repeat.set(2, 2);
        texture.encoding = THREE.sRGBEncoding;
        
        const groundGeo = new THREE.PlaneGeometry(160, 160, 64, 64);
        const groundMat = new THREE.MeshStandardMaterial({ 
            map: texture,
            bumpMap: texture,
            bumpScale: 0.15,
            roughness: 0.85, 
            metalness: 0.02 
        });
        const ground = new THREE.Mesh(groundGeo, groundMat);
        ground.rotation.x = -Math.PI / 2;
        ground.receiveShadow = true;
        scene.add(ground);
    });

    // Handle Resize
    const resizeObserver = new ResizeObserver(() => {
        if (!container) return;
        camera.aspect = container.clientWidth / container.clientHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(container.clientWidth, container.clientHeight);
    });
    resizeObserver.observe(container);

    // Animation Loop
    function animate() {
        requestAnimationFrame(animate);
        controls.update();
        renderer.render(scene, camera);
    }
    animate();
};

window.updateAgriPvScene = function(configJson) {
    if (!scene) return;
    try {
        const config = JSON.parse(configJson);
        buildProceduralFarm(config);
    } catch (e) {
        console.error("Failed to parse AgriPV Config", e);
    }
};

function buildProceduralFarm(config) {
    // Clear old instances
    if (instancedPanels) scene.remove(instancedPanels);
    if (instancedStilts) scene.remove(instancedStilts);
    if (instancedFrames) scene.remove(instancedFrames);
    if (instancedBeams) scene.remove(instancedBeams);
    if (instancedBases) scene.remove(instancedBases);
    if (instancedCrops) scene.remove(instancedCrops);
    if (boundaryLine) scene.remove(boundaryLine);

    const farmL = config.farmL || 60.0;
    const farmW = config.farmW || 60.0;
    const tilt = config.tiltRad || 0.35;
    const spacing = config.spacing || 6.0;
    const stiltH = config.stiltH || 3.5;
    const panelW = config.panelW || 4.2;
    const panelChord = config.panelChord || 2.2;
    
    // --- 1. Parse Boundary Coordinates ---
    let polygon = null;
    if (config.boundaryCoords && config.boundaryCoords.length >= 3) {
        polygon = config.boundaryCoords.map(coord => {
            const parts = coord.split(',');
            return { x: parseFloat(parts[0]), z: parseFloat(parts[1]) };
        });
        
        // Build 3D Fence
        const points = [];
        for (let i = 0; i < polygon.length; i++) {
            points.push(new THREE.Vector3(polygon[i].x, 0.5, polygon[i].z));
        }
        const lineGeo = new THREE.BufferGeometry().setFromPoints(points);
        const lineMat = new THREE.LineBasicMaterial({ color: 0x388E3C, linewidth: 3 });
        boundaryLine = new THREE.LineLoop(lineGeo, lineMat);
        scene.add(boundaryLine);
    }
    
    const rows = Math.floor(farmL / spacing);
    const cols = Math.floor(farmW / (panelW + 0.5));
    const totalPanels = rows * cols;
    if (totalPanels <= 0) return;

    // --- Create Materials ---
    const cellTex = createSolarCellTexture();
    const leafTex = createLeafTexture();
    
    const panelMat = new THREE.MeshPhysicalMaterial({
        map: cellTex,
        color: 0xffffff, // White allows texture to show properly
        metalness: 0.5,  // Less pure mirror
        roughness: 0.2,
        clearcoat: 0.8,
        clearcoatRoughness: 0.1,
        reflectivity: 0.5,
        envMapIntensity: 1.0
    });
    const metalMat = new THREE.MeshStandardMaterial({
        color: 0x90A4AE, // Galvanized steel
        metalness: 0.8,
        roughness: 0.4
    });
    const concreteMat = new THREE.MeshStandardMaterial({
        color: 0x888888, // Concrete
        metalness: 0.0,
        roughness: 0.9
    });
    const leafMat = new THREE.MeshStandardMaterial({
        map: leafTex,
        alphaTest: 0.5, // cutout transparency
        side: THREE.DoubleSide,
        roughness: 0.8,
        metalness: 0.0
    });

    // --- Create Geometries ---
    const panelGeo = new THREE.BoxGeometry(panelW, 0.02, panelChord);
    
    // Silver Frame (slightly larger than panel, hollow center simulated by thickness)
    const frameGeo = new THREE.BoxGeometry(panelW + 0.04, 0.04, panelChord + 0.04);
    
    // Pillars (Vertical)
    const stiltGeo = new THREE.CylinderGeometry(0.06, 0.06, stiltH, 8);
    stiltGeo.translate(0, stiltH / 2, 0);
    
    // Concrete Bases
    const baseGeo = new THREE.CylinderGeometry(0.15, 0.20, 0.4, 8);
    baseGeo.translate(0, 0.2, 0);
    
    // Cross Beams (Horizontal connecting pillars)
    const beamGeo = new THREE.BoxGeometry(panelW, 0.08, 0.08);

    // Crop Geometries (Cross-planes)
    const cropGeo = new THREE.PlaneGeometry(1.2, 1.2);
    cropGeo.translate(0, 0.6, 0); // rest on ground

    // --- Create Instanced Meshes ---
    instancedPanels = new THREE.InstancedMesh(panelGeo, panelMat, totalPanels);
    instancedFrames = new THREE.InstancedMesh(frameGeo, metalMat, totalPanels);
    instancedStilts = new THREE.InstancedMesh(stiltGeo, metalMat, totalPanels * 2);
    instancedBases = new THREE.InstancedMesh(baseGeo, concreteMat, totalPanels * 2);
    instancedBeams = new THREE.InstancedMesh(beamGeo, metalMat, totalPanels);
    
    // Assuming approx 15 crop plants per panel area
    const totalCrops = totalPanels * 15;
    instancedCrops = new THREE.InstancedMesh(cropGeo, leafMat, totalCrops);

    // Shadows
    [instancedPanels, instancedFrames, instancedStilts, instancedBeams, instancedCrops].forEach(m => {
        m.castShadow = true;
        m.receiveShadow = true;
    });
    instancedBases.receiveShadow = true;

    const dummy = new THREE.Object3D();
    const stiltDummy = new THREE.Object3D();
    const cropDummy = new THREE.Object3D();
    
    let index = 0;
    let stiltIndex = 0;
    let cropIndex = 0;

    const startX = -((cols - 1) * (panelW + 0.5)) / 2;
    const startZ = -((rows - 1) * spacing) / 2;

    for (let r = 0; r < rows; r++) {
        const z = startZ + r * spacing;
        for (let c = 0; c < cols; c++) {
            const x = startX + c * (panelW + 0.5);
            
            // Mask placement using Point-in-Polygon (Raycasting)
            if (polygon && !pointInPolygon(x, z, polygon)) {
                continue;
            }
            
            // 1. Panels & Frames
            dummy.position.set(x, stiltH, z);
            dummy.rotation.set(tilt, 0, 0);
            dummy.updateMatrix();
            instancedPanels.setMatrixAt(index, dummy.matrix);
            
            // Frame is just slightly offset
            dummy.position.set(x, stiltH - 0.01, z);
            dummy.updateMatrix();
            instancedFrames.setMatrixAt(index, dummy.matrix);
            
            // 2. Horizontal Cross-Beam
            dummy.position.set(x, stiltH - 0.05, z);
            dummy.rotation.set(0, 0, 0); // Flat horizontal beam
            dummy.updateMatrix();
            instancedBeams.setMatrixAt(index, dummy.matrix);

            // 3. Vertical Pillars & Concrete Bases (2 per panel)
            const leftX = x - panelW * 0.4;
            const rightX = x + panelW * 0.4;
            
            stiltDummy.position.set(leftX, 0, z);
            stiltDummy.rotation.set(0, 0, 0);
            stiltDummy.updateMatrix();
            instancedStilts.setMatrixAt(stiltIndex, stiltDummy.matrix);
            instancedBases.setMatrixAt(stiltIndex, stiltDummy.matrix);
            stiltIndex++;
            
            stiltDummy.position.set(rightX, 0, z);
            stiltDummy.updateMatrix();
            instancedStilts.setMatrixAt(stiltIndex, stiltDummy.matrix);
            instancedBases.setMatrixAt(stiltIndex, stiltDummy.matrix);
            stiltIndex++;
            
            // 4. Volumetric Crops (underneath and between)
            // Spawn multiple crops around this panel
            for (let i = 0; i < 15; i++) {
                // Random position within the panel's "plot"
                const cx = x + (Math.random() - 0.5) * panelW;
                const cz = z + (Math.random() - 0.5) * spacing;
                
                // Mask crops as well
                if (polygon && !pointInPolygon(cx, cz, polygon)) continue;
                
                cropDummy.position.set(cx, 0, cz);
                
                // Random scale and rotation for organic look
                const scale = 0.6 + Math.random() * 0.6;
                cropDummy.scale.set(scale, scale, scale);
                cropDummy.rotation.set(0, Math.random() * Math.PI, 0);
                
                cropDummy.updateMatrix();
                instancedCrops.setMatrixAt(cropIndex++, cropDummy.matrix);
            }

            index++;
        }
    }

    instancedPanels.count = index;
    instancedFrames.count = index;
    instancedBeams.count = index;
    instancedStilts.count = stiltIndex;
    instancedBases.count = stiltIndex;
    instancedCrops.count = cropIndex;

    instancedPanels.instanceMatrix.needsUpdate = true;
    instancedFrames.instanceMatrix.needsUpdate = true;
    instancedBeams.instanceMatrix.needsUpdate = true;
    instancedStilts.instanceMatrix.needsUpdate = true;
    instancedBases.instanceMatrix.needsUpdate = true;
    instancedCrops.instanceMatrix.needsUpdate = true;

    scene.add(instancedPanels);
    scene.add(instancedFrames);
    scene.add(instancedBeams);
    scene.add(instancedStilts);
    scene.add(instancedBases);
    scene.add(instancedCrops);

    // Update Sun Position if provided
    if (config.sunAzimuthRad !== undefined && config.sunElevationRad !== undefined) {
        const radius = 200; // further out
        const el = config.sunElevationRad;
        const az = config.sunAzimuthRad;
        
        // Convert spherical to cartesian
        const px = radius * Math.cos(el) * Math.sin(az);
        const py = radius * Math.sin(el);
        const pz = radius * Math.cos(el) * Math.cos(az);
        
        sunLight.position.set(px, py, pz);
        
        // Update Sky Shader
        let sceneSky = null;
        scene.children.forEach(c => {
            if (c.material && c.material.uniforms && c.material.uniforms.sunPosition) sceneSky = c;
        });
        if (sceneSky) {
            // Apply atmospheric scattering parameters
            sceneSky.material.uniforms['turbidity'].value = 2.0;
            sceneSky.material.uniforms['rayleigh'].value = 1.2;
            sceneSky.material.uniforms['mieCoefficient'].value = 0.005;
            sceneSky.material.uniforms['mieDirectionalG'].value = 0.8;
            sceneSky.material.uniforms['sunPosition'].value.copy(sunLight.position);
        }
    }
}

// Point-in-Polygon Raycasting Algorithm
function pointInPolygon(x, z, polygon) {
    let isInside = false;
    let j = polygon.length - 1;
    for (let i = 0; i < polygon.length; i++) {
        const pi = polygon[i];
        const pj = polygon[j];
        if ((pi.z > z) !== (pj.z > z) &&
            x < (pj.x - pi.x) * (z - pi.z) / (pj.z - pi.z) + pi.x) {
            isInside = !isInside;
        }
        j = i;
    }
    return isInside;
}

// Procedural Solar Cell Texture
function createSolarCellTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 512;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');
    
    // Base blue polycrystalline color with slight gradient
    const grad = ctx.createLinearGradient(0, 0, 512, 256);
    grad.addColorStop(0, '#1565C0'); // Bright blue
    grad.addColorStop(1, '#0D47A1'); // Deep blue
    ctx.fillStyle = grad;
    ctx.fillRect(0, 0, 512, 256);
    
    ctx.strokeStyle = '#E0E0E0';
    ctx.lineWidth = 1;
    ctx.globalAlpha = 0.8;
    
    for (let y = 0; y <= 256; y += 32) {
        ctx.beginPath();
        ctx.moveTo(0, y);
        ctx.lineTo(512, y);
        ctx.stroke();
    }
    for (let x = 0; x <= 512; x += 32) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, 256);
        ctx.stroke();
    }
    ctx.lineWidth = 4;
    ctx.globalAlpha = 0.95;
    for (let x = 64; x < 512; x += 128) {
        ctx.beginPath();
        ctx.moveTo(x, 0);
        ctx.lineTo(x, 256);
        ctx.stroke();
    }
    
    const texture = new THREE.CanvasTexture(canvas);
    texture.wrapS = THREE.RepeatWrapping;
    texture.wrapT = THREE.RepeatWrapping;
    texture.needsUpdate = true;
    texture.anisotropy = renderer.capabilities.getMaxAnisotropy();
    return texture;
}

// Procedural Volumetric Crop Texture
function createLeafTexture() {
    const canvas = document.createElement('canvas');
    canvas.width = 256;
    canvas.height = 256;
    const ctx = canvas.getContext('2d');
    
    ctx.clearRect(0, 0, 256, 256);
    
    ctx.fillStyle = '#2E7D32';
    ctx.beginPath();
    ctx.ellipse(128, 180, 80, 100, 0, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.fillStyle = '#388E3C';
    ctx.beginPath();
    ctx.ellipse(80, 120, 60, 80, -0.5, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.fillStyle = '#4CAF50';
    ctx.beginPath();
    ctx.ellipse(170, 100, 50, 70, 0.5, 0, Math.PI * 2);
    ctx.fill();
    
    ctx.strokeStyle = '#1B5E20';
    ctx.lineWidth = 4;
    ctx.beginPath();
    ctx.moveTo(128, 256);
    ctx.lineTo(128, 80);
    ctx.moveTo(128, 180);
    ctx.lineTo(80, 120);
    ctx.moveTo(128, 150);
    ctx.lineTo(170, 100);
    ctx.stroke();
    
    const texture = new THREE.CanvasTexture(canvas);
    texture.needsUpdate = true;
    return texture;
}
