#include <iostream>
#include "../inc/functions.hpp" 
 

namespace project {

	using namespace std;

	void WriteLine(string Text)
	{
		cout << Text  << endl;
	}
	void Write(string Text)
	{
		cout << Text;
	}

	int ReadInteger(string Message)
	{
		WriteLine(Message);
		int value = 0;
		cin >> value;
		return value;	
	}

	string ReadString(string Message)
	{
		WriteLine(Message);
		char Input[80];  
		cin.getline(Input, sizeof(Input) - 1);		 
		return Input;	
	}

}
