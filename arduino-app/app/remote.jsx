import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  StyleSheet, 
  SafeAreaView, 
  StatusBar, 
  Dimensions, 
  FlatList 
} from 'react-native';
import * as ScreenOrientation from 'expo-screen-orientation';
import { BleManager } from 'react-native-ble-plx';

const App = () => {
  const [connected, setConnected] = useState(false);
  const [devices, setDevices] = useState([]);
  const [dimensions, setDimensions] = useState({
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height,
  });
  const [manager, setManager] = useState(null);
  const [device, setDevice] = useState(null);

  useEffect(() => {
    const setLandscape = async () => {
      try {
        await ScreenOrientation.lockAsync(
          ScreenOrientation.OrientationLock.LANDSCAPE
        );
      } catch (error) {
        console.log('Error setting orientation:', error);
      }
    };

    setLandscape();

    const subscription = Dimensions.addEventListener('change', ({ window }) => {
      setDimensions({
        width: window.width,
        height: window.height,
      });
    });

    return () => {
      subscription?.remove();
      ScreenOrientation.unlockAsync();
    };
  }, []);

  useEffect(() => {
    const bleManager = new BleManager();
    setManager(bleManager);

    return () => {
      bleManager.destroy();
    };
  }, []);

  const handleScan = () => {
    if (!manager) return;

    manager.startDeviceScan(null, null, (error, scannedDevice) => {
      if (error) {
        console.log(error);
        return;
      }

      if (scannedDevice.name && scannedDevice.name.includes('HC-05')) {
        setDevices((prevDevices) => {
          return [...prevDevices, scannedDevice];
        });
      }
    });
  };

  const handleConnect = (deviceToConnect) => {
    if (deviceToConnect) {
      deviceToConnect
        .connect()
        .then((device) => {
          setDevice(device);
          setConnected(true);
          console.log('Connected to:', device.name);
        })
        .catch((error) => {
          console.log('Connection error:', error);
        });
    }
  };

  const handlePress = (direction) => {
    if (device) {
      console.log(`${direction} button pressed`);
      // Here you can send data to the HC-05 (for example, via Bluetooth characteristic write)
    }
  };

  const renderItem = ({ item }) => (
    <TouchableOpacity
      onPress={() => handleConnect(item)}
      style={styles.deviceItem}
    >
      <Text style={styles.deviceText}>{item.name}</Text>
    </TouchableOpacity>
  );

  const screenWidth = Math.max(dimensions.width, dimensions.height);
  const screenHeight = Math.min(dimensions.width, dimensions.height);

  return (
    <SafeAreaView style={[styles.container, { width: screenWidth, height: screenHeight }]}>
      <StatusBar barStyle="light-content" backgroundColor="#1a1a2e" />

      <View style={styles.mainLayout}>
        <View style={styles.headerSection}>
          <TouchableOpacity style={styles.iconButton}>
            <Text style={styles.iconText}>🏠</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.iconButton}>
            <Text style={styles.iconText}>⚙️</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.remoteContainer}>
          <View style={styles.remote}>
            <View style={styles.centerSection}>
              <TouchableOpacity onPress={() => handlePress('UP')} style={styles.button}>
                <Text style={styles.buttonText}>▲</Text>
              </TouchableOpacity>

              <View style={styles.horizontalButtons}>
                <TouchableOpacity onPress={() => handlePress('LEFT')} style={styles.button}>
                  <Text style={styles.buttonText}>◀</Text>
                </TouchableOpacity>
                <TouchableOpacity
                  style={[styles.button]}
                  onPress={() => handleConnectionToggle()}
                >
                  <Text
                    style={[connected ? styles.connectedButton : styles.disconnectedButton]}
                  />
                </TouchableOpacity>
                <TouchableOpacity onPress={() => handlePress('RIGHT')} style={styles.button}>
                  <Text style={styles.buttonText}>▶</Text>
                </TouchableOpacity>
              </View>

              <TouchableOpacity onPress={() => handlePress('DOWN')} style={styles.button}>
                <Text style={styles.buttonText}>▼</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>

        <View style={styles.deviceList}>
          <Text style={styles.deviceListTitle}>Available Devices</Text>
          <FlatList
            data={devices}
            keyExtractor={(item) => item.id}
            renderItem={renderItem}
          />
          <TouchableOpacity onPress={handleScan} style={styles.scanButton}>
            <Text style={styles.scanButtonText}>Scan for HC-05</Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  // Your existing styles here
  deviceList: {
    marginTop: 20,
    alignItems: 'center',
  },
  deviceListTitle: {
    fontSize: 18,
    color: '#fff',
    marginBottom: 10,
  },
  deviceItem: {
    backgroundColor: '#0f3460',
    padding: 10,
    marginBottom: 10,
    borderRadius: 5,
    width: '80%',
    alignItems: 'center',
  },
  deviceText: {
    color: '#fff',
    fontSize: 16,
  },
  scanButton: {
    backgroundColor: '#2ecc71',
    padding: 10,
    borderRadius: 5,
    marginTop: 20,
  },
  scanButtonText: {
    color: '#fff',
    fontSize: 16,
  },
});

export default App;
