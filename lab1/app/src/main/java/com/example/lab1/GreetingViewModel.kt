import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class GreetingViewModel : ViewModel() {
    private val _text = MutableStateFlow("Hello, Compose, from Eduard)")

    private val _clickCount = MutableStateFlow(0)
    val clickCount: StateFlow<Int> = _clickCount

    private val _messages = MutableStateFlow(listOf("Welcome!"))
    val messages: StateFlow<List<String>> = _messages

    private val _timeSinceLastClick = MutableStateFlow(0L)
    val timeSinceLastClick: StateFlow<Long> = _timeSinceLastClick

    fun incrementClickCount() {
        _clickCount.value++
        _messages.value = _messages.value + "New message #${_clickCount.value}"
        resetTimer()
    }

    fun resetAll() {
        _clickCount.value = 0
        _messages.value = listOf("Welcome!")
        resetTimer()
    }

    fun updateTimer() {
        _timeSinceLastClick.value++
    }

    fun resetTimer() {
        _timeSinceLastClick.value = 0
    }

    fun changeText() {
        viewModelScope.launch {
            val randomText = listOf(
                "Hello, World!",
                "Welcome to Compose!",
                "Button clicked!",
                "Random text here!"
            ).random()
            _text.value = randomText
        }
    }
}