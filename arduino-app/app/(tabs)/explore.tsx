import React from 'react';
import { View, Text, StyleSheet, ScrollView, Image, Linking,ActivityIndicator } from 'react-native';
import { useFonts } from 'expo-font';
import { Lobster_400Regular } from '@expo-google-fonts/lobster';

const AboutPage = () => {
   const [fontsLoaded] = useFonts({
  Lobster_400Regular
    });
  
    if (!fontsLoaded) {
      return <ActivityIndicator size="large" color="#0000ff" />;
    }
  return (
    <ScrollView style={styles.container}>

      <View style={styles.section}>
        <View>
        <Text style={styles.header}>Project Overview</Text>
        </View>
        <Text style={styles.description}> 
          The system allows you to manage your devices remotely using your phone or through voice commands, 
          and automate common tasks to make your life easier.
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.heading}>Features</Text>
        <Text style={styles.description}>
          - <Text style={styles.bold}>Bluetooth Control:</Text>
          The system communicates with the Arduino via Bluetooth.
        </Text>
        <Text style={styles.description}>
          - <Text style={styles.bold}>Voice Control:</Text> Voice commands are processed to control devices.
        </Text>
        <Text style={styles.description}>
          - <Text style={styles.bold}>Automation:</Text> Automatically control devices based on specific conditions.
        </Text>
      </View>



      <View style={styles.section}>
        <Text style={styles.heading}>How It Works</Text>
        <Text style={styles.description}>
          The app connects to your Arduino device via Bluetooth. Once connected, you can control various device.
          You can also use voice commands to control these devices or 
          set up automation tasks for convenience.
        </Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.heading}>Visit Our Project</Text>
        <Text
          style={styles.link}
          onPress={() => Linking.openURL('https://github.com/NikitaMulam2005/Arduino-Car-Application')}
        >
          Visit GitHub 
        </Text>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 30,
  },
  section: {
    marginBottom: 20,
  },
  header:{
    fontSize: 30,
    textAlign:'center',
    textDecorationLine:'underline',
    fontFamily:'Lobster_400Regular',
    color: 'rgb(50, 85, 131)', // Deep blue color for headings
    margin: 20,
  },
  heading: {
    fontSize: 24,
    fontFamily:'Lobster_400Regular',
    color: 'rgb(50, 85, 131)', // Deep blue color for headings
    marginBottom: 10,
  },
  description: {
    fontSize: 16,
    lineHeight: 22,
    color: 'rgb(60, 60, 60)', // Grayish color for regular text
  },
  bold: {
    fontWeight: '700',

  },
  projectImage: {
    width: '100%',
    height: 250,
    borderRadius: 10,
    marginTop: 10,
    marginBottom: 20,
  },
  link: {
    fontSize: 16,
    color: 'rgb(123, 163, 216)', // Soft blue color for links
    textDecorationLine: 'underline',
    fontWeight: 'bold',
    marginBottom:40
  },
});

export default AboutPage;
