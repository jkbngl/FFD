import React, { Component } from 'react';
import { StyleSheet, Text, View, Picker, Button, Alert, TextInput } from 'react-native';
import { Header } from 'react-native-elements';
import { createBottomTabNavigator } from 'react-navigation-tabs';
import { LineChart, BarChart, PieChart, ProgressChart, ContributionGraph, StackedBarChart} from "react-native-chart-kit";
import { Dimensions } from "react-native";
import { createAppContainer } from 'react-navigation';
import Icon from "react-native-vector-icons/FontAwesome";
//import CardView from 'react-native-cardview';



export default class App extends React.Component {
  render() {
    return (
        <AppContainer />
    );
  }
}

class HomeScreen extends React.Component {
  state = {
    year: '2019',
    month: 'Jan',
    day: 'First'
  };

  render() {
    return(
      <View style={{flex: 1}}>
        <View style={{flex: .2}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Home', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{flexDirection: 'row', justifyContent: 'center'}}>
          <Picker
            selectedValue={this.state.year}
            style={{height: 120, width: 100}}
            onValueChange={(itemValue, itemIndex) =>
              this.setState({year: itemValue})
            }              >
            <Picker.Item label="Year" value="defaule_none" />
            <Picker.Item label="2019" value="2019" />
            <Picker.Item label="2020" value="2020" />
            <Picker.Item label="2021" value="2021" />
          </Picker>

          <Picker
            selectedValue={this.state.month}
            style={{height: 120, width: 100}}
            onValueChange={(itemValue, itemIndex) =>
              this.setState({month: itemValue})
            }>
            <Picker.Item label="Month" value="defaule_none" />
            <Picker.Item label="Jan" value="1" />
            <Picker.Item label="Feb" value="2" />
            <Picker.Item label="Mar" value="3" />
            <Picker.Item label="Other" value="-1" />
          </Picker>

          <Picker
            selectedValue={this.state.day}
            style={{height: 120, width: 100}}
            onValueChange={(itemValue, itemIndex) =>
              this.setState({day: itemValue})
            }>
            <Picker.Item label="Day" value="defaule_none" />
            <Picker.Item label="First" value="1" />
            <Picker.Item label="Second" value="2" />
            <Picker.Item label="Third" value="3" />
            <Picker.Item label="Other" value="-1" />
          </Picker>

        </View>

        <View style={styles.container}>
          <View style={styles.alternativeLayoutButtonContainer}>
            <Text style={styles.box}>Budget:{"\n"}800</Text>
            <Text style={styles.box}>Actual:{"\n"}400</Text>
            {/*  
            <CardView
                cardElevation={2}
                cardMaxElevation={2}
                cornerRadius={5}>
              <Text>
                Elevation 0
              </Text>
            </CardView>
            */}

          </View>
        </View>
      </View>
    );
  }
}

class AccountInput extends React.Component {
  state = {
    level1: 'default_none',
    level2: 'default_none',
    level3: 'default_none',
    level1_new: 'default_none',
    level2_new: 'default_none',
    level3_new: 'default_none',
  };

  constructor(props) {
    super(props);
    this.state = {
       data : []
    };
  
  }

  componentDidMount() {
    var request = new XMLHttpRequest();
    var data;

    request.onreadystatechange = (e) => {
      if (request.readyState !== 4) {
        return;
      }
    
      if (request.status === 200) {
        data = request.responseText;

        Alert.alert(data);
        console.log('error');
    
        // Replace with fetch from API
        your_array_from_fetch=[
          {"name":"nani"},
          {"name":"banani"},
          {"name":"jakob"}
        ];     
        
        this.setState({ data: your_array_from_fetch });    
      } else {
        console.warn('error - http_code: ' + request.status);
      }
    };

    request.open('GET', 'http://192.168.0.20:5000/api/people');
    request.send();
  }

  handleClick() {

    var payload = {}

    Alert.alert(
      'Accounts saved',
      "Existing Account: "
      + this.state.level1 + "."
      + this.state.level2 + "." 
      + this.state.level3 + "\n"
      + "New Account: "
      + this.state.level1_new + "."
      + this.state.level2_new + "." 
      + this.state.level3_new,
      [
      //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
      {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
      {text: 'OK', onPress: () => console.log("test")},
      ], 
      { cancelable: false }
    )

    payload.level1 = this.state.level1;
    payload.level2 = this.state.level2;
    payload.level3 = this.state.level3;
    payload.level1_new = this.state.level1_new;
    payload.level1_new = this.state.level1_new;
    payload.level1_new = this.state.level1_new;

    Alert.alert("json parsed payload", JSON.stringify(payload));

    your_array_from_fetch=[
      {"name":"test"},
      {"name":"banani"},
      {"name":"jakob"}
    ];    

    this.setState({ data: your_array_from_fetch });

  }

  render() {  
    return(
      <View style={{flex: 1}}>
        
        <View style={{flex: .2}}>
          <Header
            statusBarProps={{ barStyle: 'light-content' }}
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Accounts', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{flex: .8, justifyContent: 'space-around', alignItems: 'center'}}>
          <View style={{justifyContent: 'center'}}>
            <Picker
              selectedValue={this.state.level1}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level1: itemValue})
              }>
              {
                 this.state.data.map((item) =>{
                   return(
                   <Picker.Item  label={item.name} value={item.name} key={item.name}/>
                   );
                 })
               }
            </Picker>

            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the name of your new level 1, e.g. Car!"
              ref= {(el) => { this.level1_new = el; }}
              onChangeText={(level1_new) => this.setState({level1_new})}
              //value={this.state.level1_new}          
            />

            <Picker
              selectedValue={this.state.level2}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level2: itemValue})
              }>
              {
                 this.state.data.map((item) =>{
                   return(
                   <Picker.Item  label={item.name} value={item.name} key={item.name}/>
                   );
                 })
               }
            </Picker>

            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the name of your new level 2, e.g. Repairs!"
              ref= {(el) => { this.level2_new = el; }}
              onChangeText={(level2_new) => this.setState({level2_new})}
              //value={this.state.level2_new}          
            />


            <Picker
              selectedValue={this.state.level3}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level3: itemValue})
              }>
              <Picker.Item label="Select existing or enter new Level 3" value="defaule_none" />
              <Picker.Item label="JavaScript" value="js" />
            </Picker>

            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the name of your new level 3, e.g. Motor!"
              ref= {(el) => { this.level3_new = el; }}
              onChangeText={(level3_new) => this.setState({level3_new})}
              //value={this.state.level3_new}          
            />

          </View>
          
          <View style={{height: 100, width: 200}}>
          <Button
                title="Save"
                color="#081A3F"
                onPress={() => this.handleClick()}
                /*
                onPress={() => Alert.alert(
                  'Accounts saved',
                  "Existing Account: "+ this.state.level1 + "."
                  + this.state.level2 + "." 
                  + this.state.level3 + "\n"
                  + "New Account: "+ this.state.level1_new + "."
                  + this.state.level2_new + "." 
                  + this.state.level3_new + "\n",
                  [
                  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                  {text: 'OK', onPress: () => Alert.alert("test")},
                  ], 
                  { cancelable: false }
                  )
                }  
                */                
              />
          </View>
        </View>
      </View>
    );
  }
}

class BudgetInput extends React.Component {
  state = {
    year: '2019',
    month: 'Jan',
    day: 'First',
    level1: 'default_none',
    level2: 'default_none',
    level3: 'default_none',
  };
  
  render() {
    return(
      <View style={{flex: 1}}>
        <View style={{flex: .2}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Budget', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{flex: .8, justifyContent: 'space-around', alignItems: 'center'}}>
          <View style={{flexDirection: 'row'}}>
          <Picker
              selectedValue={this.state.year}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({year: itemValue})
              }              >
              <Picker.Item label="Year" value="defaule_none" />
              <Picker.Item label="2019" value="2019" />
              <Picker.Item label="2020" value="2020" />
              <Picker.Item label="2021" value="2021" />
            </Picker>

            <Picker
              selectedValue={this.state.month}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({month: itemValue})
              }>
              <Picker.Item label="Month" value="defaule_none" />
              <Picker.Item label="Jan" value="1" />
              <Picker.Item label="Feb" value="2" />
              <Picker.Item label="Mar" value="3" />
              <Picker.Item label="Other" value="-1" />
            </Picker>

            <Picker
              selectedValue={this.state.day}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({day: itemValue})
              }>
              <Picker.Item label="Day" value="defaule_none" />
              <Picker.Item label="First" value="1" />
              <Picker.Item label="Second" value="2" />
              <Picker.Item label="Third" value="3" />
              <Picker.Item label="Other" value="-1" />
            </Picker>

          </View>
        
          <View style={{flex: 1.7}}>
          <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the value of your budget, e.g. 50!"
              ref= {(el) => { this.budget = el; }}
              onChangeText={(budget) => this.setState({budget})}
              value={this.state.budget}          
            />

            <Picker
              selectedValue={this.state.level1}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level1: itemValue})
              }>
              <Picker.Item label="Select Level 1" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
            <Picker
              selectedValue={this.state.level2}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level2: itemValue})
              }>
              <Picker.Item label="Select or leave empty - Level 2" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
            <Picker
              selectedValue={this.state.level3}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level3: itemValue})
              }>
              <Picker.Item label="Select or leave empty - Level 3" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
          </View>
          <View style={{flex: 1, height: 100, width: 200}}>
          <Button
                title="Save"
                color="#081A3F"
                onPress={() => Alert.alert(
                  'Budget saved',
                  "Date: " + this.state.year + "." 
                  + this.state.month + "." 
                  + this.state.day + "\n" 
                  + "Account: "+ this.state.level1 + "."
                  + this.state.level2 + "." 
                  + this.state.level3 + "\n"
                  + "Value: " + this.state.budget,
                  [
                  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                  {text: 'OK', onPress: () => console.log('OK Pressed')},
                  ], 
                  { cancelable: false }
                  )
                }                  
              />
            </View>
        </View>
      </View>
    );
  }
}


class ActualInput extends React.Component {
  state = {
    year: '2019',
    month: 'Jan',
    day: 'First',
    level1: 'default_none',
    level2: 'default_none',
    level3: 'default_none',
    costtype: 'default_none'
  };
  

  render() {

    return(

      <View style={{flex: 1}}>
        <View style={{flex: .2}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Actuals', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>

        <View style={{flex: .8, justifyContent: 'space-around', alignItems: 'center'}}>
          <View style={{flexDirection: 'row'}}>
            <Picker
              selectedValue={this.state.year}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({year: itemValue})
              }              >
              <Picker.Item label="Year" value="defaule_none" />
              <Picker.Item label="2019" value="2019" />
              <Picker.Item label="2020" value="2020" />
              <Picker.Item label="2021" value="2021" />
            </Picker>

            <Picker
              selectedValue={this.state.month}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({month: itemValue})
              }>
              <Picker.Item label="Month" value="defaule_none" />
              <Picker.Item label="Jan" value="1" />
              <Picker.Item label="Feb" value="2" />
              <Picker.Item label="Mar" value="3" />
              <Picker.Item label="Other" value="-1" />
            </Picker>

            <Picker
              selectedValue={this.state.day}
              style={{height: 120, width: 100}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({day: itemValue})
              }>
              <Picker.Item label="Day" value="defaule_none" />
              <Picker.Item label="First" value="1" />
              <Picker.Item label="Second" value="2" />
              <Picker.Item label="Third" value="3" />
              <Picker.Item label="Other" value="-1" />
            </Picker>

          </View>
        
          <View style={{flex: 2}}>
            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the value of your actual, e.g. 20!"
              ref= {(el) => { this.actual = el; }}
              onChangeText={(actual) => this.setState({actual})}
              value={this.state.actual}          
            />

            <Picker
              selectedValue={this.state.level1}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level1: itemValue})
              }>
              <Picker.Item label="Select Level 1" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
            <Picker
              selectedValue={this.state.level2}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level2: itemValue})
              }>
              <Picker.Item label="Select or leave empty - Level 2" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
            <Picker
              selectedValue={this.state.level3}
              style={{height: 50, width: 300}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({level3: itemValue})
              }>
              <Picker.Item label="Select or leave empty - Level 3" value="defaule_none" />
              <Picker.Item label="weekly" value="weekly" />
              <Picker.Item label="yearly" value="yearly" />
            </Picker>
            
            <Picker
              selectedValue={this.state.costtype}
              style={{alignSelf: "flex-end", height: 50, width: 150}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({costtype: itemValue})
              }>
              <Picker.Item label="Select type" value="defaule_none" />
              <Picker.Item label="fixed" value="fixed" />
              <Picker.Item label="variable" value="variable" />
            </Picker>  

          </View>
                    

          <View style={{flex: 1, height: 100, width: 200}}>
              <Button
                title="Save"
                color="#081A3F"
                onPress={() => Alert.alert(
                  'Actual saved',
                  "Date: " + this.state.year + "." 
                  + this.state.month + "." 
                  + this.state.day + "\n" 
                  + "Account: "+ this.state.level1 + "."
                  + this.state.level2 + "." 
                  + this.state.level3 + "\n"
                  + "Value: " + this.state.actual + "\n"
                  + "CostType: "+ this.state.costtype + "."
                  ,
                  [
                  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                  {text: 'OK', onPress: () => console.log('OK Pressed')},
                  ], 
                  { cancelable: false }
                  )
                }                  
              />
            </View>
        </View>
      </View>
    );
  }
}


class VisualizerScreen extends React.Component {
  render() {
    return(
      <View style={{flex: 1}}>
        <View style={{flex: .5}}>
          <Header
            placement="left"
            /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
            centerComponent={{ text: 'FFD - Budget', style: { color: '#fff' } }}
            rightComponent={{ icon: 'home', color: '#fff' }}
          />
        </View>
        
        
        <View style={{flex: 2, justifyContent: 'center', alignItems: 'center'}}>
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
            height={Dimensions.get("window").height - Dimensions.get("window").height / 3}
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
    justifyContent: 'space-around',
    alignItems: 'center'
  },
  box:
  {
    //color: 'green',   // debug test
    elevation:4,
    shadowOffset: { width: 5, height: 5 },
    shadowColor: "grey",
    shadowOpacity: 0.5,
    shadowRadius: 10  
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