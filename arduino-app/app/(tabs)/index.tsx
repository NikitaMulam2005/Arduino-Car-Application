import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet, SafeAreaView, Image,ActivityIndicator} from 'react-native';
import { useFonts } from 'expo-font';
import { Lobster_400Regular } from '@expo-google-fonts/lobster';

const ControlScreen = ()=> {
  const [fontsLoaded] = useFonts({
Lobster_400Regular
  });

  if (!fontsLoaded) {
    return <ActivityIndicator size="large" color="#0000ff" />;
  }
  return (
    <SafeAreaView style={styles.container}>
      <Text style={styles.header}>Make Your Life Simpler With Our Automation Control</Text>
      <Image source={require('../../assets/images/car.png')} style={styles.icon}  resizeMode="contain" />
      <View style={{ flex: 1, justifyContent: 'center', alignItems: 'center' }}>
      <TouchableOpacity style={styles.button} onPress={() => console.log("Button Pressed!")}>
      <Text style={styles.buttonText}>Get Started</Text>
      </TouchableOpacity>
      <Text style={styles.account}>Already have an account ? <Text style={{color:'rgb(123, 163, 216)'}}>Sign In</Text></Text>
    </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    paddingTop: 20,
  },
  account:{
    fontSize:15,
    margin:20,

  },
 header:{
  textAlign:'center',
  fontSize:25,
  padding:10,
  marginTop:100,
  fontWeight:'400',
  fontFamily:'Lobster_400Regular',
  color:'rgb(9, 12, 12)',
 },
 icon:{
  width:'100%',
  height:300,
 },
 button: {
  backgroundColor: 'rgb(50, 85, 131)', 
  paddingVertical: 12,         
  paddingHorizontal: 32,       
  borderRadius: 8,            
  elevation: 5,               
  shadowColor: '#000',        
  shadowOffset: { width: 0, height: 2 }, 
  shadowOpacity: 0.1,        
  shadowRadius: 3,           
},
buttonText: {
  color: 'white',            
  fontSize: 18,           
  fontWeight: 'bold',        
  textAlign: 'center',       
},
});

export default ControlScreen;