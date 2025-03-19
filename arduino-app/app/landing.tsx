import React from 'react';
import { Link, Stack } from 'expo-router';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Image } from 'react-native';
import { useRouter } from 'expo-router';

const Landing = () => {
    const router = useRouter();

    return (
        <>
            <Stack.Screen options={{ title: 'Control Options' }} />
            <SafeAreaView style={styles.container}>
                <View style={styles.grid}>
                    <TouchableOpacity style={styles.card} onPress={() => router.push('/remote')}>
                        <Image source={require('../assets/images/remote.png')} style={styles.icon} />
                        <Text style={styles.cardText}>Bluetooth Car Remote</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={styles.card} onPress={() => router.push('/automate')}>
                        <Image source={require('../assets/images/automate.png')} style={styles.icon} />
                        <Text style={styles.cardText}>Bluetooth Automation</Text>
                    </TouchableOpacity>

                    <TouchableOpacity style={styles.card} onPress={() => router.push('/voice')}>
                        <Image source={require('../assets/images/mic.png')} style={styles.icon} />
                        <Text style={styles.cardText}>Bluetooth Voice Control</Text>
                    </TouchableOpacity>
                </View>

                <View style={styles.footer}>
                    <Text style={styles.footerText}>Read</Text>
                    <Text style={styles.activeFooterItem}>Control</Text>
                </View>
            </SafeAreaView>
        </>
    );
};

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: '#fff',
        alignItems: 'center',
        paddingTop: 20,
    },
    title: {
        fontSize: 24,
        fontWeight: 'bold',
        color: 'red',
    },
    grid: {
        flexDirection: 'row',
        flexWrap: 'wrap',
        justifyContent: 'space-between',
        padding: 10,
    },
    card: {
        width: '100%',
        height: 150,
        backgroundColor: 'rgb(137, 154, 174)',
        borderRadius: 20,
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
        marginBottom:20,
    },
    cardText: {
        color: 'white',
        marginTop: 10,
        fontSize:17,
    },
    icon: {
        width: 100,
        height: 100,
        resizeMode:'contain',
    },
    footer: {
        position: 'absolute', // Keep footer at the bottom of the screen
        bottom: 0,
        left: 0,
        right: 0,
        flexDirection: 'row',
        width: '100%',
        backgroundColor: 'rgb(50, 85, 131)',
        padding: 10,
        justifyContent: 'space-around',
    },
    footerText: {
        color:'white',
        fontSize: 18,
        fontWeight:'bold'
    },
    activeFooterItem: {
        fontSize: 18,
        color: 'yellow',
    },
});

export default Landing;
