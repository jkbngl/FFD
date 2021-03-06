import * as React from 'react';
//import React, { Component } from 'react';
import { StyleSheet, Text, View, Picker, Button, Alert, TextInput, Dimensions, TouchableOpacity, Animated  } from 'react-native';
import { Header, CheckBox, Input } from 'react-native-elements';
import { createBottomTabNavigator } from 'react-navigation-tabs';
import { LineChart, BarChart, PieChart, ProgressChart, ContributionGraph, StackedBarChart} from "react-native-chart-kit";
import { createAppContainer } from 'react-navigation';
import Icon from "react-native-vector-icons/FontAwesome";
import { Ionicons } from '@expo/vector-icons';
import { createMaterialTopTabNavigator } from 'react-navigation-tabs';
import { TabView, SceneMap } from 'react-native-tab-view';
import { Dropdown } from 'react-native-material-dropdown';
import { TextField, FilledTextField, OutlinedTextField } from 'react-native-material-textfield';
import { CardViewWithIcon } from "react-native-simple-card-view";
import Chart from 'react-native-chartjs';


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
    const miniCardStyle = { shadowColor: '#000000',
                            shadowOffsetWidth: 2,
                            shadowOffsetHeight: 2,
                            shadowOpacity: 0.1,
                            shadowRadius: 5,
                            bgColor: '#ffffff',
                            padding: 5,
                            margin: 5,
                            borderRadius: 3,
                            elevation: 3,
                            //height: (Dimensions.get("height").height / 2) - 50,
                            width: (Dimensions.get("window").width / 2) - 10,
    };

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
        
        <View style={{justifyContent: "center", alignItems: "center", flexDirection: 'column'}}>
          <View style={{flexDirection: 'row', marginTop: "40%"}}>
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

          <View>
            <View style={{flexDirection: 'row'}}>
              <CardViewWithIcon
                withBackground={ false }
                //androidIcon={ 'logo-github' }
                //iosIcon={ 'logo-github' }
                androidIcon={ 'md-calculator' }
                iosIcon={ 'md-calculator' }
                iconHeight={ 30 }
                iconColor={ '#333' }
                title={ 'Budget' }
                content={ "400" }
                contentFontSize={ 20 }
                titleFontSize={ 12 }
                style={ miniCardStyle }
                //content={ "Github" }
                //onPress={ () => this.setState({
                //         github       : this.state.github + 1
                //}) }
              />
              <CardViewWithIcon
                withBackground={ false }
                //androidIcon={ 'logo-youtube' }
                //iosIcon={ 'logo-youtube' }
                androidIcon={ 'logo-euro' }
                iosIcon={ 'logo-euro' }
                iconHeight={ 30 }
                iconColor={ '#ff0000' }
                title={ 'Actual' }
                content={ '500' }
                contentFontSize={ 20 }
                titleFontSize={ 12 }
                style={ miniCardStyle }
              />
            </View>
          </View>
        </View>
      </View>
    );
  }
}






class Admin extends React.Component {
  /*
  let dropdowndata = [{
    value: 'Banana',
  }, {
    value: 'Mango',
  }, {
    value: 'Pear',
  }];
  */
  state = {
    level1: 'default_none',
    level2: 'default_none',
    level3: 'default_none',
    level1_new: 'default_none',
    level2_new: 'default_none',
    level3_new: 'default_none',
    index: 0,
    routes: [
      { key: 'first', title: 'General' },
      { key: 'second', title: 'Accounts' },
      { key: 'third', title: 'Cost Types' }
    ]
  };

  /*constructor(props) {
    super(props);
    this.state = {
       data : []
    };
  }
  */

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

    your_array_from_fetch = [
      {"name":"test"},
      {"name":"banani"},
      {"name":"jakob"}
    ];    

    this.setState({ data: your_array_from_fetch });

  }

  save_accounts()
  {
    console.log("SAVES")
  }

  onSubmit = () => {
    let { current: field } = this.fieldRef;
 
    console.log(field.value());
  };

  render() {
    const dropdowndata = [
      { value: 'Upgrade' },
      { value: 'Settings' },
      { value: 'About' },
      { value: 'Sign out' }
    ];

    const FirstRoute = (args) => (
      <View style={{flex: 1, justifyContent: 'space-around', backgroundColor: '#fff', alignItems: 'center' }}>
        <View style={{flex: 1, justifyContent: 'center', marginTop: 50}}>
          {/*<Text h2 style={{color: "white", alignItems: "center", fontSize: 40}}>Level Configuration</Text>
          <Text h4 style={{color: "white", alignItems: "center", fontSize: 20}}>Disable the whole idea of levels, or remove 2nd or 3rd level</Text>*/}
    
          <CheckBox
            title='Levels'
            //checked={this.state.checked}
            containerStyle={styles.admininput}
          />
    
          <CheckBox
            center
            title='Level 1'
            //checked={this.state.checked}
            containerStyle={styles.admininput}
    
          />
          <CheckBox
            center
            title='Level 2'
            //checked={this.state.checked}
            containerStyle={styles.admininput}
    
          />
          <CheckBox
            center
            title='Level 3'
            //checked={this.state.checked}
            containerStyle={styles.admininput}
    
          />
        </View>
    
    
        <View style={{flex: 1, flexDirection: 'column', marginTop: 50}}>
          {/*<Text h2>Cost Types Configuration</Text>
          <Text h4>Disable the whole concept of cost types and work with levels only</Text>
          */}
    
          <CheckBox
            title='Cost Types'
            //checked={this.state.checked}
            containerStyle={styles.admininput}
          />
    
          <View style={{alignItems: "center", justifyContent: 'space-around', flexDirection: "row", marginTop: 30}}>
              <TouchableOpacity
                style={styles.approveButton}
                onPress={() => Alert.alert("saved")}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-save" size={32} color="white" />
                </View>
              </TouchableOpacity>
    
              <TouchableOpacity
                style={styles.declineButton}
                onPress={() => Alert.alert("reset")}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-rewind" size={32} color="white" />
                </View>
              </TouchableOpacity>
              
                {/*onPress={() => this.handleClick()}
    
                //onPress={() => Alert.alert(
                //  'Accounts saved',
                //  "Existing Account: "+ this.state.level1 + "."
                //  + this.state.level2 + "." 
                //  + this.state.level3 + "\n"
                //  + "New Account: "+ this.state.level1_new + "."
                //  + this.state.level2_new + "." 
                //  + this.state.level3_new + "\n",
                //  [
                //  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                //  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                //  {text: 'OK', onPress: () => Alert.alert("test")},
                //  ], 
                //  { cancelable: false }
                //  )
                //}  
              ///>
            */}
            </View>
        </View>
      </View>
    );

    const SecondRoute = () => (
      <View style={{flex: 1, backgroundColor: '#fff' }}>
        <View style={{flex: .8, alignItems: 'center'}}>
          <View>
            <Dropdown
              label='1 - Select existing or enter a new Level 1 below'
              data={dropdowndata}
              containerStyle={styles.admininput}
              value={this.state.value}
              onChangeText={(value) => {
                console.log(value); // gives new value OK
                this.setState({level1: value});
              }}
            />
            
            <TextField
              label='Enter the name of your new level 1, e.g. Car!'
              containerStyle={styles.admininput}
              //keyboardType='phone-pad'
              //formatText={this.formatText}
              onSubmitEditing={this.onSubmit}
              //ref={this.fieldRef}
            />
    
            <Dropdown
              label='2 - Select existing or enter new Level 2 below'
              data={dropdowndata}
              containerStyle={styles.admininput}
            />
            
            <TextField
              label='Enter the name of your new level 2, e.g. Repairs!'
              containerStyle={styles.admininput}
              //keyboardType='phone-pad'
              //formatText={this.formatText}
              //onSubmitEditing={this.onSubmit}
              //ref={this.fieldRef}
            />
    
            <Dropdown
              label='3 - Select existing or enter new Level 3 below'
              data={dropdowndata}
              containerStyle={styles.admininput}
            />
            
            <TextField
              label='Enter the name of your new level 3, e.g. Motor!'
              containerStyle={styles.admininput}
              //keyboardType='phone-pad'
              //formatText={this.formatText}
              //onSubmitEditing={this.onSubmit}
              //ref={this.fieldRef}
            />
    
            {/*
            }
            <Picker
              //selectedValue={this.state.level1}
              style={{height: 50, width: 300}}
              //onValueChange={(itemValue, itemIndex) =>
              //  this.setState({level1: itemValue})
              //}
            >
            <Picker.Item label="Select existing or enter new Level 1" value="defaule_none" />
            <Picker.Item label="JavaScript" value="js" />
            */}
            
            
            {/*  {this.state.data.map((item) =>{
                   return(
                     <Picker.Item  label={item.name} value={item.name} key={item.name}/>
                   );
                 })
               }
             */}
            
            {/*
            </Picker>
            */}
           
    
            {/*
            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the name of your new level 1, e.g. Car!"
              ref= {(el) => { this.level1_new = el; }}
              //onChangeText={(level1_new) => this.setState({level1_new})}
              //value={this.state.level1_new}          
            />
           
            <View style = {styles.campusInputView}> 
              <Input
                containerStyle = {styles.campusInputContainer}
                inputStyle = {styles.campusInput}
                placeholder = 'KAIST v2'
              />
            </View> 
            
            
    
    
            <Picker
              //selectedValue={this.state.level2}
              style={{height: 50, width: 300}}
              //onValueChange={(itemValue, itemIndex) =>
              //  this.setState({level2: itemValue})
              //}
              >
              <Picker.Item label="Select existing or enter new Level 2" value="defaule_none" />
              <Picker.Item label="JavaScript" value="js" />
              
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
              //onChangeText={(level2_new) => this.setState({level2_new})}
              //value={this.state.level2_new}          
            />
    
    
            <Picker
              //selectedValue={this.state.level3}
              style={{height: 50, width: 300}}
              //onValueChange={(itemValue, itemIndex) =>
              //  this.setState({level3: itemValue})
              //}
              >
              <Picker.Item label="Select existing or enter new Level 3" value="defaule_none" />
              <Picker.Item label="JavaScript" value="js" />
            </Picker>
    
            <TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the name of your new level 3, e.g. Motor!"
              ref= {(el) => { this.level3_new = el; }}
              //onChangeText={(level3_new) => this.setState({level3_new})}
              //value={this.state.level3_new}          
            />
            
            <Picker
              //selectedValue={this.state.costtype}
              style={{alignSelf: "flex-end", height: 50, width: 150}}
              //onValueChange={(itemValue, itemIndex) =>
              //  this.setState({costtype: itemValue})
              //}
              >
              <Picker.Item label="Select type" value="defaule_none" />
              <Picker.Item label="fixed - e.g. rent" value="fixed" />
              <Picker.Item label="variable - e.g. gas" value="variable" />
              <Picker.Item label="invest - e.g. books" value="invest" />
              <Picker.Item label="fun - e.g. cocktails" value="fun" />
            </Picker>  
            */}
    
    
            <View style={{alignItems: "center", justifyContent: 'space-around', flexDirection: "row", marginTop: 30}}>
              <TouchableOpacity
                style={styles.approveButton}
                onPress={this.save_accounts}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-add-circle" size={32} color="white" />
                </View>
              </TouchableOpacity>
    
              <TouchableOpacity
                style={styles.declineButton}
                onPress={this.onPress}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-trash" size={32} color="white" />
                </View>
              </TouchableOpacity>
              
                {/*onPress={() => this.handleClick()}
    
                //onPress={() => Alert.alert(
                //  'Accounts saved',
                //  "Existing Account: "+ this.state.level1 + "."
                //  + this.state.level2 + "." 
                //  + this.state.level3 + "\n"
                //  + "New Account: "+ this.state.level1_new + "."
                //  + this.state.level2_new + "." 
                //  + this.state.level3_new + "\n",
                //  [
                //  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                //  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                //  {text: 'OK', onPress: () => Alert.alert("test")},
                //  ], 
                //  { cancelable: false }
                //  )
                //}  
              ///>
            */}
            </View>
          </View>
        </View>
      </View>
    );
    
    const ThirdRoute = () => (
      
      <View style={{flex: 1, backgroundColor: '#fff' }}>
        <View style={{flex: .8, alignItems: 'center'}}>
          <View>
            <Dropdown
              label='1 - Select existing or enter a new Level 1 below'
              data={dropdowndata}
              containerStyle={styles.admininput}
            />
            
            <TextField
              label='Enter the name of your new level 1, e.g. Car!'
              containerStyle={styles.admininput}
              //keyboardType='phone-pad'
              //formatText={this.formatText}
              //onSubmitEditing={this.onSubmit}
              //ref={this.fieldRef}
            />
    
            <View style={{alignItems: "center", justifyContent: 'space-around', flexDirection: "row", marginTop: 30}}>
              <TouchableOpacity
                style={styles.approveButton}
                onPress={this.onPress}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-add-circle" size={32} color="white" />
                </View>
              </TouchableOpacity>
    
              <TouchableOpacity
                style={styles.declineButton}
                onPress={this.onPress}
                >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-trash" size={32} color="white" />
                </View>
              </TouchableOpacity>
              
                {/*onPress={() => this.handleClick()}
    
                //onPress={() => Alert.alert(
                //  'Accounts saved',
                //  "Existing Account: "+ this.state.level1 + "."
                //  + this.state.level2 + "." 
                //  + this.state.level3 + "\n"
                //  + "New Account: "+ this.state.level1_new + "."
                //  + this.state.level2_new + "." 
                //  + this.state.level3_new + "\n",
                //  [
                //  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                //  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                //  {text: 'OK', onPress: () => Alert.alert("test")},
                //  ], 
                //  { cancelable: false }
                //  )
                //}  
              ///>
            */}
            </View>
          </View>
        </View>
      </View>
    );

    return (
      <View style={{flex: 1, backgroundColor: '#081A3F'}}>
        <Header
          placement="left"
          /*leftComponent={{ icon: 'menu', color: '#fff' }}*/
          centerComponent={{ text: 'FFD - Admin', style: { color: '#fff' } }}
          rightComponent={{ icon: 'home', color: '#fff' }}
        />

        <TabView
          navigationState={this.state}
          renderScene={SceneMap({
            first: FirstRoute,
            second: SecondRoute,
            third: ThirdRoute,
          })}
          onIndexChange={index => this.setState({ index })}
          initialLayout={{ width: Dimensions.get('window').width, height: 100}}
        />
      </View>
    );
  }
  

  
  /*render() {  
    return(
      <View style={{flex: 1}}>
        
        <View style={{flex: .2}}>
          <Header
            statusBarProps={{ barStyle: 'light-content' }}
            placement="left"
            //leftComponent={{ icon: 'menu', color: '#fff' }}
            centerComponent={{ text: 'FFD - Admin', style: { color: '#fff' } }}
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
            
            <Picker
              selectedValue={this.state.costtype}
              style={{alignSelf: "flex-end", height: 50, width: 150, marginTop: 35}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({costtype: itemValue})
              }>
              <Picker.Item label="Select type" value="defaule_none" />
              <Picker.Item label="fixed - e.g. rent" value="fixed" />
              <Picker.Item label="variable - e.g. gas" value="variable" />
              <Picker.Item label="invest - e.g. books" value="invest" />
              <Picker.Item label="fun - e.g. cocktails" value="fun" />
            </Picker>  
          </View>
          
          <View style={{height: 100, width: 200}}>
          <Button
                title="Save"
                color="#081A3F"
                onPress={() => this.handleClick()}
                
                //onPress={() => Alert.alert(
                //  'Accounts saved',
                //  "Existing Account: "+ this.state.level1 + "."
                //  + this.state.level2 + "." 
                //  + this.state.level3 + "\n"
                //  + "New Account: "+ this.state.level1_new + "."
                //  + this.state.level2_new + "." 
                //  + this.state.level3_new + "\n",
                //  [
                //  //{text: 'Ask me later', onPress: () => console.log('Ask me later pressed')},
                //  {text: 'Cancel', onPress: () => console.log('Cancel Pressed'), style: 'cancel'},
                //  {text: 'OK', onPress: () => Alert.alert("test")},
                //  ], 
                //  { cancelable: false }
                //  )
                //}  
                
              />
          </View>
        </View>
      </View>
    );
  }
  */
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

        <View style={{flex: 1, justifyContent: 'space-around', alignItems: 'center'}}>
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
        
          <View style={{flex: 2.5}}>
            {/*<TextInput
              style={{ height: 40, width: 300, borderColor: 'gray', borderWidth: 1, textAlign: 'center' }}
              placeholder="Enter the value of your budget, e.g. 50!"
              ref= {(el) => { this.budget = el; }}
              onChangeText={(budget) => this.setState({budget})}
              value={this.state.budget}          
            />
            */}
            <TextField
              label='Enter the value of your budget, e.g. 50!'
              containerStyle={styles.admininput}
              //keyboardType='phone-pad'
              //formatText={this.formatText}
              onSubmitEditing={this.onSubmit}
              //ref={this.fieldRef}
            />

            <View style={{marginTop: 20}}>
              <Dropdown
                label='Select Level 1'
                //data={dropdowndata}
                containerStyle={styles.admininput}
                value={this.state.value}
                onChangeText={(value) => {
                  console.log(value); // gives new value OK
                  this.setState({level1: value});
                }}
              />

              <Dropdown
                label='Select or leave empty - Level 2'
                //data={dropdowndata}
                containerStyle={styles.admininput}
                value={this.state.value}
                onChangeText={(value) => {
                  console.log(value); // gives new value OK
                  this.setState({level1: value});
                }}
              />

              <Dropdown
                label='Select or leave empty - Level 3'
                //data={dropdowndata}
                containerStyle={styles.admininput}
                value={this.state.value}
                onChangeText={(value) => {
                  console.log(value); // gives new value OK
                  this.setState({level1: value});
                }}
              />

              <Dropdown
                label='Select costype'
                //data={dropdowndata}
                containerStyle={styles.costtypeinput}
                /*
                  Select type
                  fixed - e.g. rent
                  variable - e.g. gas
                  invest - e.g. books
                  fun - e.g. cocktails
                 */
              />

              <TouchableOpacity
                style={styles.saveButton}
                onPress={() => Alert.alert("saved")}
              >
                <View style={{ alignItems: 'center', justifyContent: 'center' }} >
                  <Ionicons name="ios-save" size={32} color="white" />
                </View>
              </TouchableOpacity>

            </View>

            {/*
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
              style={{alignSelf: "flex-end", height: 50, width: 150, marginTop: 15}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({costtype: itemValue})
              }>
              <Picker.Item label="Select type" value="defaule_none" />
              <Picker.Item label="fixed - e.g. rent" value="fixed" />
              <Picker.Item label="variable - e.g. gas" value="variable" />
              <Picker.Item label="invest - e.g. books" value="invest" />
              <Picker.Item label="fun - e.g. cocktails" value="fun" />
            </Picker>  
            */}
            
          </View>
          {/*<View style={{flex: 1, height: 100, width: 200}}>
            
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
            */}
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
        
          <View style={{flex: 2.5}}>
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
              style={{alignSelf: "flex-end", height: 50, width: 150, marginTop: 15}}
              onValueChange={(itemValue, itemIndex) =>
                this.setState({costtype: itemValue})
              }>
              <Picker.Item label="Select type" value="defaule_none" />
              <Picker.Item label="fixed - e.g. rent" value="fixed" />
              <Picker.Item label="variable - e.g. gas" value="variable" />
              <Picker.Item label="invest - e.g. books" value="invest" />
              <Picker.Item label="fun - e.g. cocktails" value="fun" />
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
    const chartConfiguration = {
      type: 'bar',
      data: {
        labels: ["Red", "Blue", "Yellow", "Green", "Purple", "Orange"],
        datasets: [{
          label: '# of Votes',
          data: [12, 19, 3, 5, 2, 3],
          backgroundColor: [
            'rgba(255, 99, 132, 0.2)',
            'rgba(54, 162, 235, 0.2)',
            'rgba(255, 206, 86, 0.2)',
            'rgba(75, 192, 192, 0.2)',
            'rgba(153, 102, 255, 0.2)',
            'rgba(255, 159, 64, 0.2)'
          ],
          borderColor: [
            'rgba(255,99,132,1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 206, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)',
            'rgba(255, 159, 64, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        maintainAspectRatio : false,
        scales: {
          yAxes: [{
            ticks: {
              beginAtZero: true
            }
          }]
        }
      }
    }; 
  
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
          <Chart 
            chartConfiguration = {
              chartConfiguration
            }
            defaultFontSize={20}
          />  

          {/*<Graph customConfig={{height: 250, width: 200, heights: [12,200,31,61,25, 120, 213, 123, 65], color: '#ff0000'}}/>
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
            width={Dimensions.get("window").width * .9} // from react-native
            height={Dimensions.get("window").height * .6}
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
          */}
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
   justifyContent: 'center',
  },
  horizontalLayout: {
    // margin: 5,
    // flexDirection: 'row',
    // justifyContent: 'space-around',
    // alignItems: 'center'
  },
  box:
  {
    //color: 'green',   // debug test
    elevation:4,
    shadowOffset: { width: 5, height: 5 },
    shadowColor: "grey",
    shadowOpacity: 0.5,
    shadowRadius: 10  
  },
  scene: {
    flex: 1,
  },
  approveButton: {
    alignItems: 'center',
    backgroundColor: '#005005',
    width: "40%",
    height: 60,
    padding: 10,
    borderRadius: 50,
  },
  declineButton: {
    alignItems: 'center',
    backgroundColor: '#7f0000',
    width: "40%",
    height: 60,
    padding: 10,
    borderRadius: 50,
  },
  saveButton: {
    alignItems: 'center',
    marginTop: 30,
    backgroundColor: '#081A3F',
    justifyContent: 'center',
    alignSelf: 'center',
    width: "80%",
    height: "15%",
    padding: 10,
    borderRadius: 50,
  },
  campusInputView: {
    //flex: 1,
    justifyContent:"center",
    alignItems:"center"
  },
  campusInputContainer: {
    alignItems: 'stretch', 
    paddingHorizontal: 0
  },
  campusInput: {
    //flex: 1,
    paddingVertical: 0,
    fontFamily: 'Helvetica',
  },
  admininput:{
    width: Dimensions.get('window').width * .8,
    height: 60
  },
  costtypeinput: {
    alignSelf: "flex-end",
    height: 50,
    width: 150,
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
    Budget: {
      screen: BudgetInput,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          //<Icon name="ios-admin" size={25} color={tintColor} />
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
    Admin: {
      screen: Admin,
      navigationOptions: {
        tabBarIcon: ({ tintColor }) => (
          //<Icon name="android-settings" size={25} color={tintColor} />
          <Icon name="user" size={25} color={tintColor} />
        ),
        header: {
          style: {
              elevation: 0,       //remove shadow on Android
              shadowOpacity: 0,   //remove shadow on iOS
          }
        }
      }
    },    // Remove this komma is not needed anymore
  },
  {
    initialRouteName: 'Home',
    tabBarOptions: {
      activeTintColor: '#081A3F'
    }
  }
);

const AppContainer = createAppContainer(bottomTabNavigator);

/*const TabScreen = createMaterialTopTabNavigator(
  {
    Settings: { screen: SecondPage },
  },
  {
    tabBarPosition: 'top',
    swipeEnabled: true,
    animationEnabled: true,
    tabBarOptions: {
      activeTintColor: '#FFFFFF',
      inactiveTintColor: '#F8F8F8',
      style: {
        backgroundColor: '#633689',
      },
      labelStyle: {
        textAlign: 'center',
      },
      indicatorStyle: {
        borderBottomColor: '#87B56A',
        borderBottomWidth: 2,
      },
    },
  }
);
*/
