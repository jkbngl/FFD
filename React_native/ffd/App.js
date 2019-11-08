import React from 'react';
import { StyleSheet, Text, View, Picker, Button, Alert, TextInput } from 'react-native';
import { Header } from 'react-native-elements';
import { createBottomTabNavigator } from 'react-navigation-tabs';
import { LineChart, BarChart, PieChart, ProgressChart, ContributionGraph, StackedBarChart} from "react-native-chart-kit";
import { Dimensions } from "react-native";
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
          <Text>Budget:{"\n"}800</Text>
          <Text style={{color: 'green'}}>Actual:{"\n"}400</Text>
        </View>
      </View>
      </View>
    );
  }
}

class AccountInput extends React.Component {
  render() {  
    return(
      <View style={{flex: 1}}>
        
        <View style={{flex: 1}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Accounts', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{flex: 2, justifyContent: 'center', alignItems: 'center'}}>
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
      </View>
    );
  }
}

class BudgetInput extends React.Component {
  render() {
    return(
      <View style={{flex: .7, backgroundColor: '#fff'}}>
        
        <View style={{flex: 1}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Budget', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{backgroundColor: 'white', flex: 0.3}} />

        <View style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'stretch',
          
        }}>
        
        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Year" value="defaule_none" />
          <Picker.Item label="2019" value="2019" />
          <Picker.Item label="2020" value="2020" />
          <Picker.Item label="2021" value="2021" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Month" value="defaule_none" />
          <Picker.Item label="Jan" value="1" />
          <Picker.Item label="Feb" value="2" />
          <Picker.Item label="Mar" value="3" />
          <Picker.Item label="Other" value="-1" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Day" value="defaule_none" />
          <Picker.Item label="First" value="1" />
          <Picker.Item label="Second" value="2" />
          <Picker.Item label="Third" value="3" />
          <Picker.Item label="Other" value="-1" />
        </Picker>

        </View>
        
        <View style={{flex: 2, justifyContent: 'center', alignItems: 'center'}}>


        
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
          <Picker.Item label="Select Level 1" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select or leave empty - Level 2" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select or leave empty - Level 3" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Button
          title="Save"
          color="#081A3F"
          onPress={() => Alert.alert('Budget will be saved')}
        />
        </View>
      </View>
    );
  }
}

class ActualInput extends React.Component {
  render() {
    return(
      <View style={{flex: .7, justifyContent: 'center', alignItems: 'center', backgroundColor: '#fff'}}>
        <View style={{backgroundColor: 'white', flex: 0.3}} />

        <View style={{
          flex: 1,
          flexDirection: 'row',
          justifyContent: 'center',
          alignItems: 'stretch',
        }}>
        
        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Year" value="defaule_none" />
          <Picker.Item label="2019" value="2019" />
          <Picker.Item label="2020" value="2020" />
          <Picker.Item label="2021" value="2021" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Month" value="defaule_none" />
          <Picker.Item label="Jan" value="1" />
          <Picker.Item label="Feb" value="2" />
          <Picker.Item label="Mar" value="3" />
          <Picker.Item label="Other" value="-1" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 120, width: 100}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Day" value="defaule_none" />
          <Picker.Item label="First" value="1" />
          <Picker.Item label="Second" value="2" />
          <Picker.Item label="Third" value="3" />
          <Picker.Item label="Other" value="-1" />
        </Picker>

        </View>
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
          <Picker.Item label="Select Level 1" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select or leave empty - Level 2" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Picker
          //selectedValue={this.state.language}
          style={{height: 50, width: 300}}
          onValueChange={(itemValue, itemIndex) =>
            this.setState({language: itemValue})
          }>
          <Picker.Item label="Select or leave empty - Level 3" value="defaule_none" />
          <Picker.Item label="weekly" value="weekly" />
          <Picker.Item label="yearly" value="yearly" />
        </Picker>

        <Button
          title="Save"
          color="#081A3F"
          onPress={() => Alert.alert('Actuals will be saved')}
        />
      </View>
    );
  }
}


class VisualizerScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1, justifyContent: 'center', alignItems: 'center'}}>
        <LineChart
          data={{
            labels: ["January", "February", "March", "April", "May", "June"],
            datasets: [
              {
                data: [
                  Math.random() * 100,
                  Math.random() * 100,
                  Math.random() * 100,
                  Math.random() * 100,
                  Math.random() * 100,
                  Math.random() * 100
                ]
              }
            ]
          }}
          width={Dimensions.get("window").width - Dimensions.get("window").width / 10} // from react-native
          height={Dimensions.get("window").height - Dimensions.get("window").height / 5}
          yAxisLabel={"$"}
          yAxisSuffix={"k"}
          chartConfig={{
            backgroundColor: "#e26a00",
            backgroundGradientFrom: "#fb8c00",
            backgroundGradientTo: "#ffa726",
            decimalPlaces: 2, // optional, defaults to 2dp
            color: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
            labelColor: (opacity = 1) => `rgba(255, 255, 255, ${opacity})`,
            style: {
              borderRadius: 16
            },
            propsForDots: {
              r: "6",
              strokeWidth: "2",
              stroke: "#ffa726"
            }
          }}
          bezier
          style={{
            marginVertical: 8,
            borderRadius: 16
          }}
          />
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
      screen: AccountInput,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Budget: {
      screen: BudgetInput,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Actual: {
      screen: ActualInput,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          <Icon name="user" size={25} color={tintColor} />
        )
      }
    },
    Visualizer: {
      screen: VisualizerScreen,
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