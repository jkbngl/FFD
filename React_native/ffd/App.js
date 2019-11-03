import React from 'react';
import { StyleSheet, Text, View, Picker, Button, Alert, TextInput } from 'react-native';
import { createBottomTabNavigator } from 'react-navigation-tabs';
import { createAppContainer } from 'react-navigation';
import Icon from "react-native-vector-icons/FontAwesome";

export default class App extends React.Component {

  render() {
    return (
        <AppContainer />
    );
  }
}

class HomeScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <View style={styles.container}>
        <View style={styles.alternativeLayoutButtonContainer}>
          <Text>Budget:{"\n"}900</Text>
          <Text style={{color: 'green'}}>Actual:{"\n"}400</Text>
        </View>
      </View>
      </View>
    );
  }
}

class ExploreScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>

          <Picker.Item label="Select existing or enter new Level 1" value="default_none" />
          <Picker.Item label="JavaScript" value="js" />
        </Picker>

        <TextInput
          style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1 }}
          // onChangeText={text => onChangeText(text)}
          // value={value}
        />

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select existing or enter new Level 2" value="default_none" />
          <Picker.Item label="JavaScript" value="js" />
        </Picker>

        <TextInput
          style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1 }}
          // onChangeText={text => onChangeText(text)}
          // value={value}
        />

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select existing or enter new Level 3" value="defaule_none" />
          <Picker.Item label="JavaScript" value="js" />
        </Picker>

        <TextInput
          style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1 }}
          // onChangeText={text => onChangeText(text)}
          // value={value}
        />

        <Button
          title="Save"
          color="#081A3F"
          onPress={() => Alert.alert('Accounts will be saved')}
        />
      </View>
    );
  }
}

class NotificationsScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff'}}>
        <Text> This is my Notifications screen </Text>
      </View>
    );
  }
}

class ProfileScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#d0d0d0'}}>
        <Text> This is my Profile screen </Text>
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
    margin: 5,
    flexDirection: 'row',
    justifyContent: 'space-between'
  }
});

const bottomTabNavigator = createBottomTabNavigator(
  {
    Home: {
      screen: HomeScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="home" size={25} color={tintColor} />
        )
      }
    },
    Accounts: {
      screen: ExploreScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Budget: {
      screen: NotificationsScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Actual: {
      screen: ProfileScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Visualizer: {
      screen: ProfileScreen,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
  },
  {
    initialRouteName: 'Home',
    tabBarOptions: {
      activeTintColor: '#eb6e3d'
    }
  }
);

const AppContainer = createAppContainer(bottomTabNavigator);