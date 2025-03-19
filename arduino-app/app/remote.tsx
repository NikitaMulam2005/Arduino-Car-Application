import React, { useState, useEffect } from 'react';
import { 
  View, 
  Text, 
  TouchableOpacity, 
  StyleSheet, 
  SafeAreaView, 
  StatusBar, 
  Dimensions,
} from 'react-native';
import * as ScreenOrientation from 'expo-screen-orientation';

const App: React.FC = () => {
  const [connected, setConnected] = useState(false);
  const [dimensions, setDimensions] = useState({
    width: Dimensions.get('window').width,
    height: Dimensions.get('window').height,
  });

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

  const screenWidth = Math.max(dimensions.width, dimensions.height);
  const screenHeight = Math.min(dimensions.width, dimensions.height);

  const handleConnectionToggle = () => setConnected(!connected);
  const handlePress = (direction: string) => console.log(`${direction} button pressed`);

  return (
    <SafeAreaView style={[styles.container, { width: screenWidth, height: screenHeight }]}>
      <StatusBar barStyle="light-content" backgroundColor="#1a1a2e" />
      
      <View style={styles.mainLayout}>
        {/* Header */}
        <View style={styles.headerSection}>
          <TouchableOpacity style={styles.iconButton}>
            <Text style={styles.iconText}>🏠</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.iconButton}>
            <Text style={styles.iconText}>⚙️</Text>
          </TouchableOpacity>
        </View>

        {/* Remote Controls */}
        <View style={styles.remoteContainer}>
          <View style={styles.remote}>
            {/* Center Section with Arrows */}
            <View style={styles.centerSection}>
              <TouchableOpacity 
                onPress={() => handlePress('UP')} 
                style={styles.button}
                activeOpacity={0.8}
              >
                <Text style={styles.buttonText}>▲</Text>
              </TouchableOpacity>
              
              <View style={styles.horizontalButtons}>
                <TouchableOpacity 
                  onPress={() => handlePress('LEFT')} 
                  style={styles.button}
                  activeOpacity={0.8}
                >
                  <Text style={styles.buttonText}>◀</Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  style={[styles.button]}
                  activeOpacity={0.8}
                  onPress={() => handleConnectionToggle()}
                >
                  <Text style={[connected ? styles.connectedButton : styles.disconnectedButton]}></Text>
                </TouchableOpacity>
                <TouchableOpacity 
                  onPress={() => handlePress('RIGHT')} 
                  style={styles.button}
                  activeOpacity={0.8}
                >
                  <Text style={styles.buttonText}>▶</Text>
                </TouchableOpacity>
              </View>
              
              <TouchableOpacity 
                onPress={() => handlePress('DOWN')} 
                style={styles.button}
                activeOpacity={0.8}
              >
                <Text style={styles.buttonText}>▼</Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
      </View>
  
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#16213e',
  },
  mainLayout: {
    flex: 1,
    flexDirection: 'column',
  },
  headerSection: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 10,
    backgroundColor: '#16213e',
    borderBottomWidth: 1,
    borderBottomColor: 'rgba(255, 255, 255, 0.1)',
  },
  iconButton: {
    width: 40,
    height: 40,
    borderRadius: 20, // Circular icons
    backgroundColor: '#0f3460',
    justifyContent: 'center',
    alignItems: 'center',
  },
  iconText: {
    fontSize: 20,
  },
  connectedButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(46, 204, 113, 0.15)',
    borderColor: '#2ecc71',
  },
  disconnectedButton: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: 'rgba(231, 76, 60, 0.15)',
    borderColor: '#e94560',
  }, 
  connectionText: {
    fontSize: 15,
    fontWeight: '600',
    color: '#fff',
  },
  remoteContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 10,
  },
  remote: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    width: '90%',
    backgroundColor: '#0f3460',
    padding: 20,
    borderRadius: 20, // Circular remote container
    borderWidth: 1,
    borderColor: 'rgba(255, 255, 255, 0.1)',
  },
  centerSection: {
    justifyContent: 'center',
    alignItems: 'center',
    gap: 35,
  },
  button: {
    width: 60,
    height: 60,
    borderRadius: 30, // Circular navigation buttons
    backgroundColor: '#1a1a2e',
    justifyContent: 'center',
    alignItems: 'center',
  },
  horizontalButtons: {
    flexDirection: 'row',
    gap:65,
  },
  buttonText: {
    fontSize: 24,
    color: '#fff',
    fontWeight: 'bold',
  },
});

export default App;