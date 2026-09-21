let scene, camera, renderer, controls;
let instancedPanels, instancedStilts;
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
    camera = new THREE.PerspectiveCamera(45, container.clientWidth / container.clientHeight, 0.1, 1000);
    camera.position.set(0, 35, 60);

    // 3. Setup Renderer
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true });
    renderer.setSize(container.clientWidth, container.clientHeight);
    renderer.shadowMap.enabled = true;
    renderer.shadowMap.type = THREE.PCFSoftShadowMap;
    // renderer.outputEncoding = THREE.sRGBEncoding; // Use default for now
    container.appendChild(renderer.domElement);

    // 4. Setup Controls
    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.maxPolarAngle = Math.PI / 2 - 0.02; // Don't go below ground

    // 5. Lighting
    const ambientLight = new THREE.HemisphereLight(0xffffff, 0x444444, 0.4);
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

    // 6. Ground Plane
    const textureLoader = new THREE.TextureLoader();
    // Path relative to web build
    textureLoader.load('assets/assets/images/farm_satellite.jpg', function(texture) {
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.repeat.set(1, 1);
        
        const groundGeo = new THREE.PlaneGeometry(160, 160);
        const groundMat = new THREE.MeshStandardMaterial({ 
            map: texture, 
            roughness: 0.8, 
            metalness: 0.05 
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

    const farmL = config.farmL || 60.0;
    const farmW = config.farmW || 60.0;
    const tilt = config.tiltRad || 0.35;
    const spacing = config.spacing || 6.0;
    const stiltH = config.stiltH || 3.5;
    const panelW = config.panelW || 4.2;
    const panelChord = config.panelChord || 2.2;
    
    const rows = Math.floor(farmL / spacing);
    const cols = Math.floor(farmW / (panelW + 0.5));
    
    const totalPanels = rows * cols;
    if (totalPanels <= 0) return;

    // --- Create Panel Instanced Mesh ---
    const panelGeo = new THREE.BoxGeometry(panelW, 0.05, panelChord);
    const panelMat = new THREE.MeshPhysicalMaterial({
        color: 0x1A237E, // Deep blue
        metalness: 0.8,
        roughness: 0.2,
        clearcoat: 1.0,
        clearcoatRoughness: 0.1,
        reflectivity: 1.0
    });
    
    instancedPanels = new THREE.InstancedMesh(panelGeo, panelMat, totalPanels);
    instancedPanels.castShadow = true;
    instancedPanels.receiveShadow = true;

    // --- Create Stilt Instanced Mesh ---
    // 2 stilts per panel
    const stiltGeo = new THREE.CylinderGeometry(0.06, 0.06, stiltH, 8);
    stiltGeo.translate(0, stiltH / 2, 0);
    const stiltMat = new THREE.MeshStandardMaterial({
        color: 0x90A4AE, // Galvanized steel
        metalness: 0.7,
        roughness: 0.4
    });
    instancedStilts = new THREE.InstancedMesh(stiltGeo, stiltMat, totalPanels * 2);
    instancedStilts.castShadow = true;
    instancedStilts.receiveShadow = true;

    const dummy = new THREE.Object3D();
    const stiltDummy = new THREE.Object3D();
    
    let index = 0;
    let stiltIndex = 0;

    const startX = -((cols - 1) * (panelW + 0.5)) / 2;
    const startZ = -((rows - 1) * spacing) / 2;

    for (let r = 0; r < rows; r++) {
        const z = startZ + r * spacing;
        for (let c = 0; c < cols; c++) {
            const x = startX + c * (panelW + 0.5);
            
            // Position Panel
            dummy.position.set(x, stiltH, z);
            dummy.rotation.set(tilt, 0, 0);
            dummy.updateMatrix();
            instancedPanels.setMatrixAt(index, dummy.matrix);

            // Position Stilts
            stiltDummy.position.set(x - panelW * 0.4, 0, z);
            stiltDummy.updateMatrix();
            instancedStilts.setMatrixAt(stiltIndex++, stiltDummy.matrix);
            
            stiltDummy.position.set(x + panelW * 0.4, 0, z);
            stiltDummy.updateMatrix();
            instancedStilts.setMatrixAt(stiltIndex++, stiltDummy.matrix);

            index++;
        }
    }

    instancedPanels.instanceMatrix.needsUpdate = true;
    instancedStilts.instanceMatrix.needsUpdate = true;

    scene.add(instancedPanels);
    scene.add(instancedStilts);

    // Update Sun Position if provided
    if (config.sunAzimuthRad !== undefined && config.sunElevationRad !== undefined) {
        const radius = 80;
        const el = config.sunElevationRad;
        const az = config.sunAzimuthRad;
        sunLight.position.set(
            radius * Math.cos(el) * Math.sin(az),
            radius * Math.sin(el), // Y is UP
            radius * Math.cos(el) * Math.cos(az)
        );
    }
}
