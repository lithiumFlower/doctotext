#ifndef DOCTOTEXT_EXCEPTION_H
#define DOCTOTEXT_EXCEPTION_H

#include <exception>
#include <list>
#include <string>

namespace doctotextex
{
	/**
		This class is implementation of std::exception, which is used by DocToText.
		In this implementation, errors can be formed in "stack".

		In order to create exception just call:
		\code
		throw CustomException("First error");
		\endcode

		You can catch exception and add one more error:
		\code
		catch (CustomException& ex)
		{
			ex.appendError("Next error message");
			throw;
		}
		\endcode

		or you can catch exception and get "backtrace":
		\code
		catch (CustomException& ex)
		{
			std::cerr << ex.getBacktrace();
		}
		\endcode
	**/
	class CustomException : public std::exception
	{
		private:
			struct Implementation;
			Implementation* impl;

		public:

			CustomException() throw();

			/**
				The constructor.
				\param first_error_message first error message (gives information about cause of an error).
			**/
			CustomException(const std::string& first_error_message) throw();

			CustomException(const CustomException& ex) throw();

			~CustomException() throw();

			CustomException& operator = (const CustomException& ex) throw();

			const char* what(){ return "doctotext_exception"; }

			/**
				returns a string with all error messages. Each error message is separated by "\n".
				Suppose we have thrown an exception:
				\code
				throw CustomException("First error message");
				\endcode
				Next, we have added one more error:
				\code
				ex.appendError("Second error message");
				\endcode
				In the result getBacktrace will return a string: "First error message\nSecond error message\n"
			**/
			std::string getBacktrace();

			/**
				Adds one more error message.
			**/
			void appendError(const std::string& error_message);

			/**
				returns a iterator to the first error message
			**/
			std::list<std::string>::iterator getErrorIterator() const;

			/**
				Returns a number of error messages
			**/
			size_t getErrorCount() const;
	};
}

#endif
