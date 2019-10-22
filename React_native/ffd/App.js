import React, { Component } from 'react';
import { Text, StyleSheet, View } from 'react-native';
import { createBottomTabNavigator, createAppContainer } from 'react-navigation';

export default class HelloWorldApp extends Component {
  render() {
    return (
      <View style={styles.container}>
        <View style={styles.alternativeLayoutButtonContainer}>
          <Text>Budget:{"\n"}900</Text>

          <Text style={{color: 'green'}}>Actual:{"\n"}400</Text>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
   flex: 1,
   justifyContent: 'center',
  },
  alternativeLayoutButtonContainer: {
    margin: 100,
    flexDirection: 'row',
    justifyContent: 'space-between'
  }
});
